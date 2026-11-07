import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct TokenOracleTests {
    private let fixtures = OracleTokenFixtures()
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")
    private let index = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")

    @Test(arguments: ["Sns", "Known", "Spam", "ChainFusionTestnet", "ChainFusion", "Community", "Native"])
    func mapsCategoryAndMetadataAndCachesResults(category: String) async throws {
        let http = try fixtures.client(count: 1, pages: [0: [fixtures.token(category: category)]])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        #expect(oracle.token(for: canister) == nil)
        #expect(http.requests.isEmpty)
        let tokens = try await oracle.allTokens()
        let expected = ICPToken(standard: category == "Native" ? .icp : .icrc1,
            canister: canister, name: "Test Token", decimals: 6, symbol: "TST",
            verified: category != "Spam", logo: URL(string: "https://example.com/token.png"))
        #expect(tokens == [expected])
        #expect(oracle.token(for: canister) == expected)
        #expect(oracle.token(for: unknown) == nil)
        #expect(try await oracle.allTokens() == tokens)
        #expect(http.requests.count == 2)
        try assertRegistryRequests(http, starts: [0])
    }

    @Test(arguments: [0, 1, 9, 10, 11, 20, 21])
    func paginationPreservesAllTokensAndRequestsPageBoundaries(count: Int) async throws {
        let records = try (0..<count).map { try fixtures.token(name: "Token \($0)") }
        var pages: [UInt64: [CandidValue]] = [:]
        for start in stride(from: 0, through: count, by: 10) {
            pages[UInt64(start)] = Array(records[start..<min(start + 10, count)])
        }
        let http = try fixtures.client(count: UInt64(count), pages: pages)
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let tokens = try await oracle.allTokens()
        #expect(tokens.count == count)
        #expect(Set(tokens.map(\.name)) == Set((0..<count).map { "Token \($0)" }))
        #expect(try await oracle.allTokens() == tokens)
        try assertRegistryRequests(http, starts: Set(pages.keys))
    }

    @Test func missingLogoAndInvalidLedgerAreHandledIndependently() async throws {
        let http = try fixtures.client(count: 2, pages: [0: [
            fixtures.token(logo: nil), fixtures.token(ledger: "not-a-principal")
        ]])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let tokens = try await oracle.allTokens()
        #expect(tokens.count == 1)
        #expect(tokens.first?.canister == canister)
        #expect(tokens.first?.logo == nil)
        #expect(try await oracle.allTokens() == tokens)
        #expect(http.requests.count == 2)
    }

    @Test func countFailurePropagatesAndNextLoadRetries() async throws {
        let countReply = try DABMockResponses.candid(UInt64(1))
        let pageReply = try CandidSerialiser().encode([.vector([fixtures.token()])])
        let attempts = TokenServiceAttemptCounter()
        let http = MockHttpClient { request in
            if attempts.next() == 1 {
                return HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            let method = try DABMockResponses.envelope(request).content.method_name
            return try TokenServiceTestResponses.reply(method == "count_icrc1_canisters" ? countReply : pageReply)
        }
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        await #expect {
            _ = try await oracle.allTokens()
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
        #expect(oracle.token(for: canister) == nil)
        #expect(http.requests.count == 1)
        #expect(try await oracle.allTokens().count == 1)
        #expect(http.requests.count == 3)
    }

    @Test(arguments: [false, true])
    func failedPagesAreSkippedAndPartialResultsAreCached(malformed: Bool) async throws {
        let http = try fixtures.client(count: 11, pages: [0: [fixtures.token()]], failedPage: 10, malformedPage: malformed)
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let tokens = try await oracle.allTokens()
        #expect(tokens.map(\.canister) == [canister])
        #expect(try await oracle.allTokens() == tokens)
        try assertRegistryRequests(http, starts: [0, 10])
    }

    @Test(arguments: [Optional<String>.none, "invalid-principal"])
    func missingOrInvalidIndexReturnsEmpty(index: String?) async throws {
        let http = try fixtures.client(count: 1, pages: [0: [fixtures.token(index: index)]])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let token = try #require(await oracle.allTokens().first)
        let user = ICPAccount.mainAccount(of: unknown)
        #expect(try await oracle.transactions(of: user, for: token).isEmpty)
        #expect(try await oracle.transactions(of: user, for: canister).isEmpty)
        #expect(http.requests.count == 2)
    }

    @Test(arguments: [false, true])
    func transactionsRouteToNativeOrConfiguredIndex(native: Bool) async throws {
        // An index error lets the test verify routing and error propagation without duplicating history fixtures.
        let reply = try DABMockResponses.candid(Index.GetTransactionsResult.Err(.init(message: "index failure")))
        let http = try fixtures.client(count: 1, pages: [0: [
            fixtures.token(category: native ? "Native" : "Known", index: index.string)
        ]], queries: ["get_account_transactions": reply])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let token = try #require(await oracle.allTokens().first)
        let user = try ICPAccount(principal: unknown, subAccountId: Data(repeating: 3, count: 32))
        for useToken in [false, true] {
            await #expect {
                if useToken { _ = try await oracle.transactions(of: user, for: token) }
                else { _ = try await oracle.transactions(of: user, for: canister) }
            } throws: { error in
                if native {
                    return (error as? ICPIndex.GetAccountIdentifierTransactionsError)?.message == "index failure"
                }
                return (error as? Index.GetTransactionsErr)?.message == "index failure"
            }
            let request = try #require(http.lastRequest)
            let content = try DABMockResponses.envelope(request).content
            #expect(content.method_name == "get_account_transactions")
            #expect(content.canister_id == (native ? ICPSystemCanisters.index : index).bytes)
            if native {
                let args = try DABMockResponses.arguments(ICPIndex.GetAccountTransactionsArgs.self, from: request)
                #expect(args.account.owner == user.principal)
                #expect(args.account.subaccount == user.subAccountId)
                #expect(args.start == nil)
                #expect(args.max_results == 1000)
            } else {
                let args = try DABMockResponses.arguments(Index.GetAccountTransactionsArgs.self, from: request)
                #expect(args.account.owner == user.principal)
                #expect(args.account.subaccount == user.subAccountId)
                #expect(args.start == nil)
                #expect(args.max_results == 1000)
            }
        }
        #expect(http.requests.count == 4)
    }

    private func assertRegistryRequests(_ http: MockHttpClient, starts: Set<UInt64>,
                                        sourceLocation: SourceLocation = #_sourceLocation) throws {
        #expect(http.requests.count == starts.count + 1, sourceLocation: sourceLocation)
        var actualStarts: [UInt64] = []
        for request in http.requests {
            let content = try DABMockResponses.envelope(request).content
            #expect(content.request_type == "query", sourceLocation: sourceLocation)
            #expect(content.canister_id == DABService.icrc1Oracle.bytes, sourceLocation: sourceLocation)
            #expect(request.url.path.hasSuffix("/\(DABService.icrc1Oracle)/query"), sourceLocation: sourceLocation)
            let args = try CandidDeserialiser().decode(#require(content.arg))
            if content.method_name == "count_icrc1_canisters" {
                #expect(args.isEmpty, sourceLocation: sourceLocation)
            } else {
                #expect(content.method_name == "get_icrc1_paginated", sourceLocation: sourceLocation)
                #expect(args.count == 2, sourceLocation: sourceLocation)
                actualStarts.append(try CandidDecoder().decode(UInt64.self, from: #require(args.first)))
                #expect(try CandidDecoder().decode(UInt64.self, from: #require(args.last)) == 10,
                        sourceLocation: sourceLocation)
            }
        }
        #expect(Set(actualStarts) == starts, sourceLocation: sourceLocation)
        #expect(actualStarts.count == starts.count, sourceLocation: sourceLocation)
    }

}
