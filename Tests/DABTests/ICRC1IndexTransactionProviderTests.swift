import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct ICRC1IndexTransactionProviderTests {
    private let indexCanister = ICPPrincipal("aaaaa-aa")
    private let owner = DABTestSigner().principal
    private var token: ICPToken {
        ICPToken(standard: .icrc1, canister: ICPSystemCanisters.ledger, name: "Test Token",
                 decimals: 8, symbol: "TST", verified: true, logo: nil)
    }

    @Test func emptyHistoryPreservesRequestAccount() async throws {
        let http = try historyClient([])
        let user = try ICPAccount(principal: owner, subAccountId: Data(repeating: 3, count: 32))
        #expect(try await provider(http).transactions(of: user).isEmpty)

        let request = try #require(http.lastRequest)
        let envelope = try DABMockResponses.envelope(request)
        let args = try DABMockResponses.arguments(Index.GetAccountTransactionsArgs.self, from: request)
        #expect(envelope.content.method_name == "get_account_transactions")
        #expect(envelope.content.canister_id == indexCanister.bytes)
        #expect(request.url.path.hasSuffix("/aaaaa-aa/query"))
        #expect(args.account.owner == owner)
        #expect(args.account.subaccount == Data(repeating: 3, count: 32))
        #expect(args.start == nil)
        #expect(args.max_results == 1000)
    }

    @Test func mapsOperationsWithoutOptionalFields() async throws {
        try await checkOperations(withOptions: false)
    }

    @Test func mapsOperationsWithOptionalFields() async throws {
        try await checkOperations(withOptions: true)
    }

    private func checkOperations(withOptions: Bool) async throws {
        let from = Index.Account(owner: owner, subaccount: nil)
        let to = Index.Account(owner: indexCanister, subaccount: Data(repeating: 2, count: 32))
        let spender = Index.Account(owner: owner, subaccount: Data(repeating: 3, count: 32))
        let memo: Data? = withOptions ? Data([4, 5]) : nil
        let created: UInt64? = withOptions ? 123_000_000_000 : nil
        let largeAmount = BigUInt(1) << 100
        let transactions: [Index.TransactionWithId] = [
            transaction(10, burn: .init(from: from, memo: memo, created_at_time: created,
                                      amount: largeAmount, spender: withOptions ? spender : nil)),
            transaction(11, approve: .init(fee: withOptions ? 8 : nil, from: from, memo: memo,
                created_at_time: created, amount: 200, expected_allowance: withOptions ? 150 : nil,
                expires_at: withOptions ? 456_000_000_000 : nil, spender: spender)),
            transaction(12, transfer: .init(to: to, fee: withOptions ? 9 : nil, from: from,
                memo: memo, created_at_time: created, amount: 300, spender: withOptions ? spender : nil)),
            transaction(13, mint: .init(to: to, memo: memo, created_at_time: created, amount: 400))
        ]
        let http = try historyClient(transactions)
        let results = try await provider(http).transactions(of: .mainAccount(of: owner))
        #expect(results.map(\.index) == [10, 11, 12, 13])
        #expect(results.map(\.amount) == [largeAmount, 200, 300, 400])
        #expect(results.map(\.fee) == (withOptions ? [0, 8, 9, 0] : [0, 0, 0, 0]))
        try #require(results.count == 4)
        for result in results {
            #expect(result.token == token)
            #expect(result.memo == nil)
            #expect(result.icrc1Memo == memo)
            #expect(result.timeStamp == Date(timeIntervalSince1970: 789))
            #expect(result.created == (withOptions ? Date(timeIntervalSince1970: 123) : nil))
        }

        guard case .burn(let burnFrom) = results[0].operation,
              case .approve(let approveFrom, let allowance, let expires) = results[1].operation,
              case .transfer(let transferFrom, let transferTo) = results[2].operation,
              case .mint(let mintTo) = results[3].operation else {
            Issue.record("Transaction operation was mapped incorrectly"); return
        }
        for destination in [burnFrom, approveFrom, transferFrom] {
            assertAccount(destination, principal: owner, subaccount: Data(repeating: 0, count: 32))
        }
        for destination in [transferTo, mintTo] {
            assertAccount(destination, principal: indexCanister, subaccount: Data(repeating: 2, count: 32))
        }
        #expect(allowance == (withOptions ? 150 : nil))
        #expect(expires == (withOptions ? Date(timeIntervalSince1970: 456) : nil))
        assertAccount(try #require(results[1].spender), principal: owner, subaccount: Data(repeating: 3, count: 32))
        for result in [results[0], results[2]] {
            if withOptions {
                assertAccount(try #require(result.spender), principal: owner, subaccount: Data(repeating: 3, count: 32))
            } else {
                #expect(result.spender == nil)
            }
        }
        #expect(results[3].spender == nil)
    }

    @Test func skipsUnknownAndMalformedTransactionsWithoutDroppingValidOnes() async throws {
        let valid = Index.Account(owner: owner, subaccount: nil)
        let invalid = Index.Account(owner: owner, subaccount: Data([1]))
        let http = try historyClient([
            transaction(1, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 10)),
            transaction(2),
            transaction(3, burn: .init(from: invalid, memo: nil, created_at_time: nil, amount: 20, spender: nil)),
            transaction(4, transfer: .init(to: valid, fee: nil, from: valid, memo: nil,
                created_at_time: nil, amount: 30, spender: invalid)),
            transaction(5, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 40))
        ])
        let results = try await provider(http).transactions(of: .mainAccount(of: owner))
        #expect(results.map(\.index) == [1, 5])
        #expect(results.map(\.amount) == [10, 40])
    }

    @Test func propagatesIndexError() async throws {
        let http = DABMockResponses.client(queries: ["get_account_transactions": try DABMockResponses.candid(
            Index.GetTransactionsResult.Err(.init(message: "Index is syncing")))])
        await #expect {
            _ = try await provider(http).transactions(of: .mainAccount(of: owner))
        } throws: { error in
            (error as? Index.GetTransactionsErr)?.message == "Index is syncing"
        }
    }

    @Test func propagatesHTTPFailure() async throws {
        let http = MockHttpClient(response: HttpResponse(statusCode: 503))
        await #expect {
            _ = try await provider(http).transactions(of: .mainAccount(of: owner))
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, _) = error else { return false }
            return code == 503
        }
    }

    private func provider(_ http: MockHttpClient) -> ICPICRC1IndexTransactionProvider {
        ICPICRC1IndexTransactionProvider(client: DABMockResponses.requestClient(http),
                                        token: token, indexCanister: indexCanister)
    }

    private func historyClient(_ transactions: [Index.TransactionWithId]) throws -> MockHttpClient {
        DABMockResponses.client(queries: [
            "get_account_transactions": try ICRC1IndexFixtures.historyReply(transactions)
        ])
    }

    private func transaction(_ id: BigUInt, burn: Index.Burn? = nil, approve: Index.Approve? = nil,
                             transfer: Index.Transfer? = nil, mint: Index.Mint? = nil) -> Index.TransactionWithId {
        let kind = burn != nil ? "burn" : approve != nil ? "approve" : transfer != nil ? "transfer" : mint != nil ? "mint" : "unknown"
        return .init(id: id, transaction: .init(burn: burn, kind: kind, mint: mint,
            approve: approve, timestamp: 789_000_000_000, transfer: transfer))
    }

    private func assertAccount(_ destination: ICPTokenTransaction.Destination, principal: ICPPrincipal,
                               subaccount: Data, sourceLocation: SourceLocation = #_sourceLocation) {
        guard case .account(let account) = destination else {
            Issue.record("Expected an ICRC account", sourceLocation: sourceLocation); return
        }
        #expect(account.principal == principal, sourceLocation: sourceLocation)
        #expect(account.subAccountId == subaccount, sourceLocation: sourceLocation)
    }

    private let fixtures = DABTokenFixtures()
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    private var icrc1IndexCanister: ICPPrincipal { ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai") }

    @Test(arguments: [false, true])
    func icrc1IndexDiscoveryIsCachedAndPreservesAccount(customSubaccount: Bool) async throws {
        let http = try icrc1HistoryClient([])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == canister })
        let account = try ICPAccount(principal: unknown,
            subAccountId: Data(repeating: customSubaccount ? 7 : 0, count: 32))

        #expect(try await service.transactions(of: account, for: token).isEmpty)
        #expect(try await service.transactions(of: account, for: canister).isEmpty)
        #expect(http.requests.count == 6)
        let discovery = try http.requests.filter {
            try DABMockResponses.envelope($0).content.method_name == "list_deployed_snses"
        }
        #expect(discovery.count == 1)
        #expect(try DABMockResponses.envelope(#require(discovery.first)).content.canister_id
                == ICPSystemCanisters.nns_sns_w.bytes)
        for request in http.requests.suffix(2) {
            let content = try DABMockResponses.envelope(request).content
            #expect(content.method_name == "get_account_transactions")
            #expect(content.request_type == "query")
            #expect(content.canister_id == icrc1IndexCanister.bytes)
            #expect(request.url.path.hasSuffix("/\(icrc1IndexCanister)/query"))
            let args = try DABMockResponses.arguments(Index.GetAccountTransactionsArgs.self, from: request)
            #expect(args.account.owner == unknown)
            #expect(args.account.subaccount == account.subAccountId)
            #expect(args.start == nil)
            #expect(args.max_results == 1000)
        }
    }

    @Test(arguments: [false, true])
    func icrc1IndexMapsOperationsThroughService(withOptions: Bool) async throws {
        let from = Index.Account(owner: DABTestSigner().principal, subaccount: nil)
        let to = Index.Account(owner: icrc1IndexCanister, subaccount: Data(repeating: 2, count: 32))
        let spender = Index.Account(owner: DABTestSigner().principal, subaccount: Data(repeating: 3, count: 32))
        let memo: Data? = withOptions ? Data([4, 5]) : nil
        let created: UInt64? = withOptions ? 123_000_000_000 : nil
        let largeAmount = BigUInt(1) << 100
        let transactions: [Index.TransactionWithId] = [
            icrc1Transaction(10, burn: .init(from: from, memo: memo, created_at_time: created,
                                      amount: largeAmount, spender: withOptions ? spender : nil)),
            icrc1Transaction(11, approve: .init(fee: withOptions ? 8 : nil, from: from, memo: memo,
                created_at_time: created, amount: 200, expected_allowance: withOptions ? 150 : nil,
                expires_at: withOptions ? 456_000_000_000 : nil, spender: spender)),
            icrc1Transaction(12, transfer: .init(to: to, fee: withOptions ? 9 : nil, from: from,
                memo: memo, created_at_time: created, amount: 300, spender: withOptions ? spender : nil)),
            icrc1Transaction(13, mint: .init(to: to, memo: memo, created_at_time: created, amount: 400))
        ]
        let http = try icrc1HistoryClient(transactions)
        let results = try await icrc1Transactions(http, of: .mainAccount(of: DABTestSigner().principal))
        #expect(results.map(\.index) == [10, 11, 12, 13])
        #expect(results.map(\.amount) == [largeAmount, 200, 300, 400])
        #expect(results.map(\.fee) == (withOptions ? [0, 8, 9, 0] : [0, 0, 0, 0]))
        try #require(results.count == 4)
        for result in results {
            #expect(result.token == ICPToken(standard: .icrc1, canister: canister, name: "Test Token",
                decimals: 6, symbol: "TST", verified: true, logo: URL(string: "https://example.com/token.png")))
            #expect(result.memo == nil)
            #expect(result.icrc1Memo == memo)
            #expect(result.timeStamp == Date(timeIntervalSince1970: 789))
            #expect(result.created == (withOptions ? Date(timeIntervalSince1970: 123) : nil))
        }

        guard case .burn(let burnFrom) = results[0].operation,
              case .approve(let approveFrom, let allowance, let expires) = results[1].operation,
              case .transfer(let transferFrom, let transferTo) = results[2].operation,
              case .mint(let mintTo) = results[3].operation else {
            Issue.record("Transaction operation was mapped incorrectly"); return
        }
        for destination in [burnFrom, approveFrom, transferFrom] {
            assertICRC1Account(destination, principal: DABTestSigner().principal, subaccount: Data(repeating: 0, count: 32))
        }
        for destination in [transferTo, mintTo] {
            assertICRC1Account(destination, principal: icrc1IndexCanister, subaccount: Data(repeating: 2, count: 32))
        }
        #expect(allowance == (withOptions ? 150 : nil))
        #expect(expires == (withOptions ? Date(timeIntervalSince1970: 456) : nil))
        assertICRC1Account(try #require(results[1].spender), principal: DABTestSigner().principal, subaccount: Data(repeating: 3, count: 32))
        for result in [results[0], results[2]] {
            if withOptions {
                assertICRC1Account(try #require(result.spender), principal: DABTestSigner().principal, subaccount: Data(repeating: 3, count: 32))
            } else {
                #expect(result.spender == nil)
            }
        }
        #expect(results[3].spender == nil)
    }

    @Test func icrc1IndexSkipsMalformedTransactionsThroughService() async throws {
        let valid = Index.Account(owner: DABTestSigner().principal, subaccount: nil)
        let invalid = Index.Account(owner: DABTestSigner().principal, subaccount: Data([1]))
        let http = try icrc1HistoryClient([
            icrc1Transaction(1, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 10)),
            icrc1Transaction(2),
            icrc1Transaction(3, burn: .init(from: invalid, memo: nil, created_at_time: nil, amount: 20, spender: nil)),
            icrc1Transaction(4, transfer: .init(to: valid, fee: nil, from: valid, memo: nil,
                created_at_time: nil, amount: 30, spender: invalid)),
            icrc1Transaction(5, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 40))
        ])
        let results = try await icrc1Transactions(http, of: .mainAccount(of: DABTestSigner().principal))
        #expect(results.map(\.index) == [1, 5])
        #expect(results.map(\.amount) == [10, 40])
    }


    @Test func icrc1IndexErrorPropagatesThroughService() async throws {
        var queries = try icrc1IndexQueries()
        queries["get_account_transactions"] = try DABMockResponses.candid(
            Index.GetTransactionsResult.Err(.init(message: "Index is syncing")))
        let http = DABMockResponses.client(queries: queries)
        await #expect {
            _ = try await icrc1Transactions(http, of: .mainAccount(of: unknown))
        } throws: { error in
            (error as? Index.GetTransactionsErr)?.message == "Index is syncing"
        }
        #expect(http.requests.count == 5)
    }

    @Test(arguments: ["list_deployed_snses", "get_account_transactions"], [false, true])
    func icrc1IndexFailuresPropagateThroughService(method: String, malformed: Bool) async throws {
        let queries = try icrc1IndexQueries()
        let http = MockHttpClient { request in
            if try DABMockResponses.envelope(request).content.method_name == method {
                return malformed ? try TokenServiceTestResponses.reply(Data([0]))
                    : HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            return try TokenServiceTestResponses.reply(for: request, queries: queries)
        }
        if malformed {
            await #expect(throws: (any Error).self) {
                _ = try await icrc1Transactions(http, of: .mainAccount(of: unknown))
            }
        } else {
            await #expect {
                _ = try await icrc1Transactions(http, of: .mainAccount(of: unknown))
            } throws: { error in
                guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
                return code == 503 && message == "unavailable"
            }
        }
        #expect(http.requests.count == (method == "list_deployed_snses" ? 4 : 5))
    }

    private func icrc1IndexQueries() throws -> [String: Data] {
        var queries = try fixtures.queries(tokens: [fixtures.registryToken()])
        queries["list_deployed_snses"] = try DABMockResponses.candid(
            NNS_SNS_W.ListDeployedSnsesResponse(instances: [
                .init(root_canister_id: unknown, governance_canister_id: nil,
                    index_canister_id: icrc1IndexCanister, swap_canister_id: nil, ledger_canister_id: canister)
            ]))
        return queries
    }

    private func icrc1HistoryClient(_ transactions: [Index.TransactionWithId]) throws -> MockHttpClient {
        var queries = try icrc1IndexQueries()
        queries["get_account_transactions"] = try ICRC1IndexFixtures.historyReply(transactions)
        return DABMockResponses.client(queries: queries)
    }

    private func icrc1Transactions(_ http: MockHttpClient, of account: ICPAccount) async throws -> [ICPTokenTransaction] {
        let service = DABTokenService(DABMockResponses.requestClient(http))
        _ = try await service.allTokens()
        return try await service.transactions(of: account, for: canister)
    }

    private func icrc1Transaction(_ id: BigUInt, burn: Index.Burn? = nil, approve: Index.Approve? = nil,
                             transfer: Index.Transfer? = nil, mint: Index.Mint? = nil) -> Index.TransactionWithId {
        let kind = burn != nil ? "burn" : approve != nil ? "approve" : transfer != nil ? "transfer" : mint != nil ? "mint" : "unknown"
        return .init(id: id, transaction: .init(burn: burn, kind: kind, mint: mint,
            approve: approve, timestamp: 789_000_000_000, transfer: transfer))
    }

    private func assertICRC1Account(_ destination: ICPTokenTransaction.Destination, principal: ICPPrincipal,
                               subaccount: Data, sourceLocation: SourceLocation = #_sourceLocation) {
        guard case .account(let account) = destination else {
            Issue.record("Expected an ICRC account", sourceLocation: sourceLocation); return
        }
        #expect(account.principal == principal, sourceLocation: sourceLocation)
        #expect(account.subAccountId == subaccount, sourceLocation: sourceLocation)
    }
}
