import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct DABTokenServiceTests {
    private let fixtures = DABTokenFixtures()
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    @Test(arguments: [false, true])
    func allTokensMapsRegistryAndLedgerAndCachesResults(verified: Bool) async throws {
        let http = try fixtures.client(tokens: [fixtures.registryToken(verified: verified)])
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
        let http = try fixtures.client(tokens: [])
        let tokens = try await DABTokenService(DABMockResponses.requestClient(http)).allTokens()
        #expect(tokens.map(\.canister) == [ICPSystemCanisters.ledger])
    }

    @Test func unsupportedStandardHasNoActor() async throws {
        let http = try fixtures.client(tokens: [fixtures.registryToken(standard: "EXT")])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == canister })
        #expect(service.actor(for: .ext, canister) == nil)
        #expect(service.actor(for: token) == nil)
        #expect(try await service.actor(for: canister) == nil)
        #expect(http.requests.count == 3)
    }

    @Test(arguments: ["standard", "decimals", "symbol", "verified"])
    func missingRegistryDetailRejectsEntireLoad(key: String) async throws {
        let http = try fixtures.client(tokens: [fixtures.registryToken(omitting: key)])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        await #expect(throws: (any Error).self) { _ = try await service.allTokens() }
        #expect(service.token(for: canister) == nil)
        #expect(service.token(for: ICPSystemCanisters.ledger) == nil)
    }

    @Test(arguments: ["standard", "decimals", "symbol", "verified", "unknownStandard"])
    func invalidRegistryDetailRejectsEntireLoad(key: String) async throws {
        let http = try fixtures.client(tokens: [fixtures.registryToken(invalid: key)])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        await #expect(throws: (any Error).self) { _ = try await service.allTokens() }
        #expect(service.token(for: canister) == nil)
    }

    @Test(arguments: ["get_all", "icrc1_metadata"])
    func failedLoadPropagatesErrorAndCanBeRetried(method: String) async throws {
        let replies = try fixtures.queries(tokens: [fixtures.registryToken()])
        // Fail the selected request once, then allow a complete retry.
        let attempts = TokenServiceAttemptCounter()
        let http = MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            if content.method_name == method && attempts.next() == 1 {
                return HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            return try TokenServiceTestResponses.reply(for: request, queries: replies)
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
}
