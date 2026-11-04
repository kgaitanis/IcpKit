import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct TokenOracleTests {
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")
    private let index = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")

    @Test(arguments: ["Sns", "Known", "Spam", "ChainFusionTestnet", "ChainFusion", "Community", "Native"])
    func mapsCategoryAndMetadataAndCachesResults(category: String) async throws {
        let http = try client(count: 1, pages: [0: [token(category: category)]])
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
        let records = try (0..<count).map { try token(name: "Token \($0)") }
        var pages: [UInt64: [CandidValue]] = [:]
        for start in stride(from: 0, through: count, by: 10) {
            pages[UInt64(start)] = Array(records[start..<min(start + 10, count)])
        }
        let http = try client(count: UInt64(count), pages: pages)
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let tokens = try await oracle.allTokens()
        #expect(tokens.count == count)
        #expect(Set(tokens.map(\.name)) == Set((0..<count).map { "Token \($0)" }))
        #expect(try await oracle.allTokens() == tokens)
        try assertRegistryRequests(http, starts: Set(pages.keys))
    }

    @Test func missingLogoAndInvalidLedgerAreHandledIndependently() async throws {
        let http = try client(count: 2, pages: [0: [
            token(logo: nil), token(ledger: "not-a-principal")
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
        let pageReply = try CandidSerialiser().encode([.vector([token()])])
        let attempts = AttemptCounter()
        let http = MockHttpClient { request in
            if attempts.next() == 1 {
                return HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            let method = try DABMockResponses.envelope(request).content.method_name
            return try Self.reply(method == "count_icrc1_canisters" ? countReply : pageReply)
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
        let http = try client(count: 11, pages: [0: [token()]], failedPage: 10, malformedPage: malformed)
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let tokens = try await oracle.allTokens()
        #expect(tokens.map(\.canister) == [canister])
        #expect(try await oracle.allTokens() == tokens)
        try assertRegistryRequests(http, starts: [0, 10])
    }

    @Test func lookupsLoadAndReuseRegistry() async throws {
        let http = try client(count: 1, pages: [0: [token()]])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        #expect(try await oracle.tokenStandard(for: canister) == .icrc1)
        #expect(try await oracle.tokenStandard(for: unknown) == nil)
        #expect(try await oracle.actor(for: unknown) == nil)
        #expect(try await oracle.actor(for: canister) is ICRC1TokenActor)
        #expect(http.requests.count == 2)
    }

    @Test(arguments: [0, 1, 2])
    func actorOverloadsUseInjectedClientAndCanister(overload: Int) async throws {
        let http = try client(count: 1, pages: [0: [token()]],
            queries: ["icrc1_balance_of": DABMockResponses.candid(BigUInt(123))])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let actor: (any ICPTokenActor)?
        switch overload {
        case 0: actor = oracle.actor(for: .icrc1, canister)
        case 1:
            let token = try #require(await oracle.allTokens().first)
            actor = oracle.actor(for: token)
        default: actor = try await oracle.actor(for: canister)
        }
        #expect(try await #require(actor).balance(of: .mainAccount(of: unknown)) == 123)
        let content = try DABMockResponses.envelope(#require(http.lastRequest)).content
        #expect(content.canister_id == canister.bytes)
        #expect(content.method_name == "icrc1_balance_of")
        #expect(http.requests.count == (overload == 0 ? 1 : 3))
    }

    @Test func unsupportedActorsDoNotRequestNetwork() throws {
        let http = try client(count: 0, pages: [0: []])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let token = ICPToken(standard: .ext, canister: canister, name: "Unsupported",
                             decimals: 0, symbol: "EXT", verified: false, logo: nil)
        #expect(oracle.actor(for: .ext, canister) == nil)
        #expect(oracle.actor(for: token) == nil)
        #expect(http.requests.isEmpty)
    }

    @Test func balanceSkipsZeroAndFailedBalancesAndPreservesAccount() async throws {
        let failed = ICPSystemCanisters.ledger
        let amount = BigUInt(1) << 100
        let http = try client(count: 3, pages: [0: [
            token(), token(ledger: index.string), token(ledger: failed.string)
        ]], balances: [canister.string: amount, index.string: 0], failedBalance: failed)
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let account = try ICPAccount(principal: unknown, subAccountId: Data(repeating: 7, count: 32))
        let holdings = try await oracle.balance(of: account)
        #expect(holdings.count == 1)
        #expect(holdings.first?.token.canister == canister)
        #expect(holdings.first?.balance == amount)
        let requests = try http.requests.filter {
            try DABMockResponses.envelope($0).content.method_name == "icrc1_balance_of"
        }
        #expect(requests.count == 3)
        for request in requests {
            let args = try DABMockResponses.arguments(ICRC1.Account.self, from: request)
            #expect(args.owner == account.principal)
            #expect(args.subaccount == account.subAccountId)
        }
    }

    @Test func transactionsRequireCachedToken() async throws {
        let http = try client(count: 1, pages: [0: [token()]])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        let user = ICPAccount.mainAccount(of: unknown)
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await oracle.transactions(of: user, for: canister)
        }
        #expect(http.requests.isEmpty)
        _ = try await oracle.allTokens()
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await oracle.transactions(of: user, for: unknown)
        }
        #expect(http.requests.count == 2)
    }

    @Test(arguments: [Optional<String>.none, "invalid-principal"])
    func missingOrInvalidIndexReturnsEmpty(index: String?) async throws {
        let http = try client(count: 1, pages: [0: [token(index: index)]])
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
        let http = try client(count: 1, pages: [0: [
            token(category: native ? "Native" : "Known", index: index.string)
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

    @Test func explorerURLsUseICPAndSNSRootsAndCacheSNSLookup() async throws {
        let sns = NNS_SNS_W.ListDeployedSnsesResponse(instances: [
            .init(root_canister_id: index, governance_canister_id: nil,
                  index_canister_id: nil, swap_canister_id: nil, ledger_canister_id: canister)
        ])
        let http = DABMockResponses.client(queries: ["list_deployed_snses": try DABMockResponses.candid(sns)])
        let oracle = TokenOracle(DABMockResponses.requestClient(http))
        #expect(try await oracle.explorerUrl(tokenCanister: ICPSystemCanisters.ledger,
            transactionIndex: "123")?.absoluteString == "https://dashboard.internetcomputer.org/transaction/123")
        #expect(http.requests.isEmpty)
        #expect(try await oracle.explorerUrl(tokenCanister: canister,
            transactionIndex: "42")?.absoluteString
            == "https://dashboard.internetcomputer.org/sns/rrkah-fqaaa-aaaaa-aaaaq-cai/transaction/42")
        #expect(try await oracle.explorerUrl(tokenCanister: unknown, transactionIndex: "42") == nil)
        #expect(http.requests.count == 1)
        #expect(try DABMockResponses.envelope(#require(http.lastRequest)).content.canister_id
                == ICPSystemCanisters.nns_sns_w.bytes)
    }

    private func token(ledger: String = "aaaaa-aa", category: String = "Known", name: String = "Test Token",
                       logo: String? = "https://example.com/token.png", index: String? = nil) throws -> CandidValue {
        // Declare every category and optional's wire type so mixed records share one vector type.
        let categories = ["Sns", "Known", "Spam", "ChainFusionTestnet", "ChainFusion", "Community", "Native"]
        return .record([
            "fee": .natural(10_000), "decimals": .natural8(6), "logo": CandidValue(logo),
            "name": .text(name), "ledger": .text(ledger), "index": CandidValue(index), "symbol": .text("TST"),
            "category": try .variant(Dictionary(uniqueKeysWithValues: categories.map { ($0, CandidType.null) }),
                                     (category, .null))
        ])
    }

    private func client(count: UInt64, pages: [UInt64: [CandidValue]], queries: [String: Data] = [:],
                        failedPage: UInt64? = nil, malformedPage: Bool = false,
                        balances: [String: BigUInt] = [:], failedBalance: ICPPrincipal? = nil) throws -> MockHttpClient {
        let countReply = try DABMockResponses.candid(count)
        let type = try token().candidType
        let pageReplies = try pages.mapValues { CandidSerialiser().encode([.vector(try CandidVector(type, $0))]) }
        return MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            let method = try #require(content.method_name)
            switch method {
            case "count_icrc1_canisters": return try Self.reply(countReply)
            case "get_icrc1_paginated":
                let args = try CandidDeserialiser().decode(#require(content.arg))
                let start = try CandidDecoder().decode(UInt64.self, from: #require(args.first))
                if start == failedPage {
                    return malformedPage ? try Self.reply(Data([0])) : HttpResponse(statusCode: 503)
                }
                return try Self.reply(#require(pageReplies[start], "Unexpected page: \(start)"))
            case "icrc1_balance_of" where !balances.isEmpty:
                if content.canister_id == failedBalance?.bytes { return HttpResponse(statusCode: 503) }
                let principal = ICPPrincipal(try #require(content.canister_id))
                return try Self.reply(DABMockResponses.candid(#require(balances[principal.string])))
            default: return try Self.reply(#require(queries[method], "Unexpected query: \(method)"))
            }
        }
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

    private static func reply(_ data: Data) throws -> HttpResponse {
        HttpResponse(data: try ICPCryptography.CBOR.serialise(QueryReply(reply: .init(arg: data))), statusCode: 200)
    }

    private struct QueryReply: Encodable {
        let status = "replied"
        let reply: Reply
        struct Reply: Encodable { let arg: Data }
    }

    private final class AttemptCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0
        func next() -> Int { lock.withLock { value += 1; return value } }
    }
}
