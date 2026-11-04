import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct DABTokenServiceTests {
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    @Test(arguments: [false, true])
    func allTokensMapsRegistryAndLedgerAndCachesResults(verified: Bool) async throws {
        let http = try client(tokens: [registryToken(verified: verified)])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        #expect(service.token(for: canister) == nil)
        #expect(http.requests.isEmpty)

        let tokens = try await service.allTokens()
        #expect(tokens.count == 2)
        let token = try #require(tokens.first { $0.canister == canister })
        #expect(token == ICPToken(standard: .icrc1, canister: canister, name: "Test Token",
                                 decimals: 6, symbol: "TST", verified: verified,
                                 logo: URL(string: "https://example.com/token.png")))
        let icp = try #require(tokens.first { $0.canister == ICPSystemCanisters.ledger })
        #expect(icp.standard == .icp)
        #expect(icp.name == "Internet Computer")
        #expect(icp.symbol == "ICP")
        #expect(icp.decimals == 8)
        #expect(icp.verified)
        #expect(icp.logo == nil)
        #expect(service.token(for: canister) == token)
        #expect(service.token(for: unknown) == nil)
        #expect(try await service.allTokens() == tokens)
        #expect(http.requests.count == 3)

        for request in http.requests {
            let content = try DABMockResponses.envelope(request).content
            #expect(content.request_type == "query")
            let expectedCanister = content.method_name == "get_all"
                ? DABService.tokenRegistry : ICPSystemCanisters.ledger
            #expect(content.canister_id == expectedCanister.bytes)
            #expect(request.url.path.hasSuffix("/\(expectedCanister)/query"))
            #expect(try CandidDeserialiser().decode(#require(content.arg)).isEmpty)
        }
        #expect(try Set(http.requests.compactMap {
            try DABMockResponses.envelope($0).content.method_name
        }) == Set(["get_all", "icrc1_metadata", "icrc1_total_supply"]))
    }

    @Test func emptyRegistryStillIncludesICP() async throws {
        let http = try client(tokens: [])
        let tokens = try await DABTokenService(DABMockResponses.requestClient(http)).allTokens()
        #expect(tokens.map(\.canister) == [ICPSystemCanisters.ledger])
    }

    @Test func lookupsLoadRegistryAndReuseCache() async throws {
        let http = try client(tokens: [registryToken()])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        #expect(try await service.tokenStandard(for: canister) == .icrc1)
        #expect(try await service.tokenStandard(for: ICPSystemCanisters.ledger) == .icp)
        #expect(try await service.tokenStandard(for: unknown) == nil)
        #expect(try await service.actor(for: unknown) == nil)
        let actor = try #require(await service.actor(for: canister))
        #expect(actor is ICRC1TokenActor)
        #expect(http.requests.count == 3)
    }

    @Test(arguments: [0, 1, 2])
    func actorOverloadsUseInjectedClientAndCanister(overload: Int) async throws {
        let http = try client(tokens: [registryToken()])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let actor: (any ICPTokenActor)?
        switch overload {
        case 0: actor = service.actor(for: .icrc1, canister)
        case 1:
            let token = try #require(await service.allTokens().first { $0.canister == canister })
            actor = service.actor(for: token)
        default: actor = try await service.actor(for: canister)
        }
        #expect(try await #require(actor).balance(of: .mainAccount(of: unknown)) == 123)
        let request = try #require(http.lastRequest)
        #expect(try DABMockResponses.envelope(request).content.canister_id == canister.bytes)
        #expect(try DABMockResponses.envelope(request).content.method_name == "icrc1_balance_of")
    }

    @Test func unsupportedStandardHasNoActor() async throws {
        let http = try client(tokens: [registryToken(standard: "EXT")])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == canister })
        #expect(service.actor(for: .ext, canister) == nil)
        #expect(service.actor(for: token) == nil)
        #expect(try await service.actor(for: canister) == nil)
        #expect(http.requests.count == 3)
    }

    @Test(arguments: ["standard", "decimals", "symbol", "verified"])
    func missingRegistryDetailRejectsEntireLoad(key: String) async throws {
        let http = try client(tokens: [registryToken(omitting: key)])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        await #expect(throws: (any Error).self) { _ = try await service.allTokens() }
        #expect(service.token(for: canister) == nil)
        #expect(service.token(for: ICPSystemCanisters.ledger) == nil)
    }

    @Test(arguments: ["standard", "decimals", "symbol", "verified", "unknownStandard"])
    func invalidRegistryDetailRejectsEntireLoad(key: String) async throws {
        let http = try client(tokens: [registryToken(invalid: key)])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        await #expect(throws: (any Error).self) { _ = try await service.allTokens() }
        #expect(service.token(for: canister) == nil)
    }

    @Test(arguments: ["get_all", "icrc1_metadata"])
    func failedLoadPropagatesErrorAndCanBeRetried(method: String) async throws {
        let replies = try queries(tokens: [registryToken()])
        // Fail the selected request once, then allow a complete retry.
        let attempts = AttemptCounter()
        let http = MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            if content.method_name == method && attempts.next() == 1 {
                return HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            return try Self.reply(for: request, queries: replies)
        }
        let service = DABTokenService(DABMockResponses.requestClient(http))
        await #expect {
            _ = try await service.allTokens()
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
        #expect(service.token(for: canister) == nil)
        #expect(service.token(for: ICPSystemCanisters.ledger) == nil)
        #expect(try await service.allTokens().count == 2)
        #expect(attempts.count == 2)
    }

    @Test func balanceKeepsPositiveHoldingsAndSkipsZeroFailedAndUnsupportedTokens() async throws {
        let zero = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
        let failed = ICPPrincipal("ryjl3-tyaaa-aaaaa-aaaba-cai")
        let unsupported = ICPPrincipal("r7inp-6aaaa-aaaaa-aaabq-cai")
        let replies = try queries(tokens: [
            registryToken(), registryToken(canister: zero),
            registryToken(canister: failed), registryToken(canister: unsupported, standard: "EXT")
        ])
        let amount = BigUInt(1) << 100
        let positive = try DABMockResponses.candid(amount)
        let empty = try DABMockResponses.candid(BigUInt.zero)
        let http = MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            if content.method_name == "icrc1_balance_of" {
                if content.canister_id == failed.bytes {
                    return HttpResponse(statusCode: 503)
                }
                return try Self.reply(for: request, queries: [
                    "icrc1_balance_of": content.canister_id == self.canister.bytes ? positive : empty
                ])
            }
            return try Self.reply(for: request, queries: replies)
        }
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let account = try ICPAccount(principal: unknown, subAccountId: Data(repeating: 7, count: 32))
        let holdings = try await service.balance(of: account)
        #expect(holdings.count == 1)
        #expect(holdings.first?.token.canister == canister)
        #expect(holdings.first?.balance == amount)
        let requests = try http.requests.filter {
            try DABMockResponses.envelope($0).content.method_name == "icrc1_balance_of"
        }
        #expect(requests.count == 4)
        for request in requests {
            #expect(try DABMockResponses.envelope(request).content.canister_id != unsupported.bytes)
            let args = try DABMockResponses.arguments(ICRC1.Account.self, from: request)
            #expect(args.owner == account.principal)
            #expect(args.subaccount == account.subAccountId)
        }
    }

    @Test func transactionsRequireCachedToken() async throws {
        let http = try client(tokens: [registryToken()])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let account = ICPAccount.mainAccount(of: unknown)
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await service.transactions(of: account, for: canister)
        }
        #expect(http.requests.isEmpty)
        _ = try await service.allTokens()
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await service.transactions(of: account, for: unknown)
        }
        #expect(http.requests.count == 3)
    }

    @Test func transactionsWithoutAnIndexReturnEmptyForBothOverloads() async throws {
        var replies = try queries(tokens: [registryToken()])
        replies["list_deployed_snses"] = try DABMockResponses.candid(
            NNS_SNS_W.ListDeployedSnsesResponse(instances: []))
        let http = DABMockResponses.client(queries: replies)
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == canister })
        let account = ICPAccount.mainAccount(of: unknown)
        #expect(try await service.transactions(of: account, for: token).isEmpty)
        #expect(try await service.transactions(of: account, for: canister).isEmpty)
        #expect(http.requests.count == 4)
        let request = try #require(http.lastRequest)
        let content = try DABMockResponses.envelope(request).content
        #expect(content.method_name == "list_deployed_snses")
        #expect(content.canister_id == ICPSystemCanisters.nns_sns_w.bytes)
    }

    @Test func snsExplorerURLUsesRootAndCachesLookup() async throws {
        let root = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
        let response = NNS_SNS_W.ListDeployedSnsesResponse(instances: [
            .init(root_canister_id: root, governance_canister_id: nil,
                  index_canister_id: nil, swap_canister_id: nil, ledger_canister_id: canister)
        ])
        let http = DABMockResponses.client(queries: [
            "list_deployed_snses": try DABMockResponses.candid(response)
        ])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        #expect(try await service.explorerUrl(tokenCanister: canister,
            transactionIndex: "42")?.absoluteString
            == "https://dashboard.internetcomputer.org/sns/rrkah-fqaaa-aaaaa-aaaaq-cai/transaction/42")
        #expect(try await service.explorerUrl(tokenCanister: unknown, transactionIndex: "42") == nil)
        #expect(http.requests.count == 1)
    }

    @Test func icpExplorerURLNeedsNoNetwork() async throws {
        let http = try client(tokens: [])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        #expect(try await service.explorerUrl(tokenCanister: ICPSystemCanisters.ledger,
            transactionIndex: "123")?.absoluteString == "https://dashboard.internetcomputer.org/transaction/123")
        #expect(http.requests.isEmpty)
    }

    private func registryToken(canister: ICPPrincipal? = nil, standard: String = "ICRC1",
                               verified: Bool = true, omitting: String? = nil,
                               invalid: String? = nil) throws -> CandidValue {
        // Every detail uses the same wire variant, even when its selected case differs.
        let types: [String: CandidType] = ["Text": .text, "U64": .natural64, "True": .null, "False": .null]
        let fields: [(String, String, CandidValue)] = [
            ("standard", "Text", .text(invalid == "unknownStandard" ? "UNKNOWN" : standard)),
            ("decimals", "U64", .natural64(6)),
            ("symbol", "Text", .text("TST")),
            ("verified", verified ? "True" : "False", .null)
        ]
        let details = try fields.filter { $0.0 != omitting }.map { key, variant, value in
            CandidValue.record([.text(key), try .variant(types,
                invalid == key ? (variant == "Text" ? "U64" : "Text",
                                  variant == "Text" ? .natural64(1) : .text("invalid")) : (variant, value))])
        }
        return .record([
            .init("thumbnail", .text("https://example.com/token.png")),
            .init("submitter", .principal(unknown.bytes)),
            .init("name", .text("Test Token")),
            .init("frontend", .option(.text)),
            .init("description", .text("Fixture")),
            .init("last_updated_at", .natural64(0)),
            .init("last_updated_by", .principal(unknown.bytes)),
            .init("details", try .vector(details)),
            .init("principal_id", .principal((canister ?? self.canister).bytes))
        ])
    }

    private func queries(tokens: [CandidValue]) throws -> [String: Data] {
        let types: [String: CandidType] = ["Nat": .natural, "Text": .text]
        let metadata = try [
            ("icrc1:name", "Text", CandidValue.text("Internet Computer")),
            ("icrc1:symbol", "Text", .text("ICP")),
            ("icrc1:decimals", "Nat", .natural(8)),
            ("icrc1:fee", "Nat", .natural(10_000))
        ].map { key, variant, value in
            CandidValue.record([.text(key), try .variant(types, (variant, value))])
        }
        let registry = tokens.isEmpty ? CandidValue.vector(try registryToken().candidType) : try .vector(tokens)
        return [
            "get_all": CandidSerialiser().encode([registry]),
            "icrc1_metadata": try CandidSerialiser().encode([.vector(metadata)]),
            "icrc1_total_supply": try DABMockResponses.candid(BigUInt(1_000_000)),
            "icrc1_balance_of": try DABMockResponses.candid(BigUInt(123))
        ]
    }

    private func client(tokens: [CandidValue]) throws -> MockHttpClient {
        DABMockResponses.client(queries: try queries(tokens: tokens))
    }

    private static func reply(for request: HttpRequest, queries: [String: Data]) throws -> HttpResponse {
        let method = try #require(DABMockResponses.envelope(request).content.method_name)
        let data = try #require(queries[method], "Unexpected query: \(method)")
        return HttpResponse(data: try ICPCryptography.CBOR.serialise(QueryReply(reply: .init(arg: data))),
                            statusCode: 200)
    }

    private struct QueryReply: Encodable {
        let status = "replied"
        let reply: Reply
        struct Reply: Encodable { let arg: Data }
    }

    private final class AttemptCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0
        var count: Int { lock.withLock { value } }
        func next() -> Int { lock.withLock { value += 1; return value } }
    }
}
