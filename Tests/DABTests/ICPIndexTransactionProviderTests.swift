import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct ICPIndexTransactionProviderTests {
    private let fixtures = DABTokenFixtures()
    private let unknown = ICPPrincipal("2vxsx-fae")

    @Test(arguments: [false, true])
    func icpIndexEmptyHistoryPreservesAccountAndRoutesToSystemIndex(customSubaccount: Bool) async throws {
        let http = try icpIndexClient(.Ok(.init(balance: 123, transactions: [], oldest_tx_id: nil)))
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == ICPSystemCanisters.ledger })
        let account = try ICPAccount(principal: unknown,
            subAccountId: Data(repeating: customSubaccount ? 7 : 0, count: 32))

        #expect(try await service.transactions(of: account, for: token).isEmpty)
        #expect(try await service.transactions(of: account, for: ICPSystemCanisters.ledger).isEmpty)
        // Registry metadata is cached, but each history request queries the index.
        #expect(http.requests.count == 5)
        for request in http.requests.suffix(2) {
            let content = try DABMockResponses.envelope(request).content
            #expect(content.request_type == "query")
            #expect(content.method_name == "get_account_transactions")
            #expect(content.canister_id == ICPSystemCanisters.index.bytes)
            #expect(request.url.path.hasSuffix("/\(ICPSystemCanisters.index)/query"))
            let args = try DABMockResponses.arguments(ICPIndex.GetAccountTransactionsArgs.self, from: request)
            #expect(args.account.owner == unknown)
            #expect(args.account.subaccount == account.subAccountId)
            #expect(args.start == nil)
            #expect(args.max_results == 1000)
        }
    }

    @Test(arguments: ["burn", "approve", "transfer", "mint"], [false, true])
    func icpIndexMapsTransactionsThroughService(kind: String, withOptions: Bool) async throws {
        let from = String(repeating: "1", count: 64)
        let to = String(repeating: "2", count: 64)
        let spender = String(repeating: "3", count: 64)
        let operation: ICPIndex.Operation
        switch kind {
        case "burn":
            operation = .Burn(from: from, amount: .init(e8s: .max), spender: withOptions ? spender : nil)
        case "approve":
            operation = .Approve(fee: .init(e8s: 10_000), from: from, allowance: .init(e8s: .max),
                expected_allowance: withOptions ? .init(e8s: 150) : nil,
                expires_at: withOptions ? .init(timestamp_nanos: 456_500_000_000) : nil, spender: spender)
        case "transfer":
            operation = .Transfer(to: to, fee: .init(e8s: 10_000), from: from,
                amount: .init(e8s: .max), spender: withOptions ? spender : nil)
        default:
            operation = .Mint(to: to, amount: .init(e8s: .max))
        }
        let transaction = ICPIndex.Transaction(memo: .max,
            icrc1_memo: withOptions ? Data([0, 255, 7]) : nil, operation: operation,
            timestamp: withOptions ? .init(timestamp_nanos: 789_250_000_000) : nil,
            created_at_time: withOptions ? .init(timestamp_nanos: 123_500_000_000) : nil)
        let http = try icpIndexClient(.Ok(.init(balance: 42, transactions: [
            .init(id: .max, transaction: transaction), .init(id: 7, transaction: transaction)
        ], oldest_tx_id: 7)))
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == ICPSystemCanisters.ledger })

        let results = try await service.transactions(of: .mainAccount(of: unknown), for: ICPSystemCanisters.ledger)
        #expect(results.map(\.index) == [BigUInt(UInt64.max), 7])
        try #require(results.count == 2)
        for result in results {
            #expect(result.token == token)
            #expect(result.amount == BigUInt(UInt64.max))
            #expect(result.fee == (kind == "approve" || kind == "transfer" ? 10_000 : 0))
            #expect(result.memo == UInt64.max)
            #expect(result.icrc1Memo == (withOptions ? Data([0, 255, 7]) : nil))
            #expect(result.timeStamp == (withOptions ? Date(timeIntervalSince1970: 789.25) : nil))
            #expect(result.created == (withOptions ? Date(timeIntervalSince1970: 123.5) : nil))
            switch (kind, result.operation) {
            case ("burn", .burn(let source)):
                assertICPAccountId(source, equals: from)
            case ("approve", .approve(let source, let allowance, let expires)):
                assertICPAccountId(source, equals: from)
                #expect(allowance == (withOptions ? 150 : nil))
                #expect(expires == (withOptions ? Date(timeIntervalSince1970: 456.5) : nil))
            case ("transfer", .transfer(let source, let destination)):
                assertICPAccountId(source, equals: from)
                assertICPAccountId(destination, equals: to)
            case ("mint", .mint(let destination)):
                assertICPAccountId(destination, equals: to)
            default:
                Issue.record("Incorrect operation for \(kind)")
            }
            if kind == "approve" || (kind != "mint" && withOptions) {
                assertICPAccountId(try #require(result.spender), equals: spender)
            } else {
                #expect(result.spender == nil)
            }
        }
        #expect(http.requests.count == 4)
        #expect(try DABMockResponses.envelope(#require(http.lastRequest)).content.canister_id
                == ICPSystemCanisters.index.bytes)
    }

    @Test func icpIndexErrorPropagatesThroughService() async throws {
        let http = try icpIndexClient(.Err(.init(message: "Index is syncing")))
        let service = DABTokenService(DABMockResponses.requestClient(http))
        _ = try await service.allTokens()

        await #expect {
            _ = try await service.transactions(of: .mainAccount(of: unknown), for: ICPSystemCanisters.ledger)
        } throws: { error in
            (error as? ICPIndex.GetAccountIdentifierTransactionsError)?.message == "Index is syncing"
        }
        #expect(http.requests.count == 4)
    }

    @Test(arguments: [false, true])
    func icpIndexRejectsFailedOrMalformedResponseThroughService(malformed: Bool) async throws {
        let queries = try fixtures.queries(tokens: [])
        let http = MockHttpClient { request in
            if try DABMockResponses.envelope(request).content.method_name == "get_account_transactions" {
                return malformed
                    ? try TokenServiceTestResponses.reply(Data([0]))
                    : HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            return try TokenServiceTestResponses.reply(for: request, queries: queries)
        }
        let service = DABTokenService(DABMockResponses.requestClient(http))
        _ = try await service.allTokens()

        if malformed {
            await #expect(throws: (any Error).self) {
                _ = try await service.transactions(of: .mainAccount(of: unknown), for: ICPSystemCanisters.ledger)
            }
        } else {
            await #expect {
                _ = try await service.transactions(of: .mainAccount(of: unknown), for: ICPSystemCanisters.ledger)
            } throws: { error in
                guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
                return code == 503 && message == "unavailable"
            }
        }
        #expect(http.requests.count == 4)
    }

    private func icpIndexClient(_ result: ICPIndex.GetAccountIdentifierTransactionsResult) throws -> MockHttpClient {
        var queries = try fixtures.queries(tokens: [])
        // Build the result variant explicitly so the encoder does not re-wrap
        // optional fields in the associated response record.
        let reply: CandidValue
        switch result {
        case .Ok(let response):
            reply = .variant(.init("Ok", try CandidEncoder().encode(response)))
        case .Err(let error):
            reply = .variant(.init("Err", try CandidEncoder().encode(error)))
        }
        queries["get_account_transactions"] = CandidSerialiser().encode([reply])
        return DABMockResponses.client(queries: queries)
    }

    private func assertICPAccountId(_ destination: ICPTokenTransaction.Destination, equals expected: String,
                                    sourceLocation: SourceLocation = #_sourceLocation) {
        guard case .accountId(let value) = destination else {
            Issue.record("Expected an ICP account identifier", sourceLocation: sourceLocation)
            return
        }
        #expect(value == expected, sourceLocation: sourceLocation)
    }
}
