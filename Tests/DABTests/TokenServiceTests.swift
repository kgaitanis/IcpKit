import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct TokenServiceTests {
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    @Test(arguments: TokenServiceBackend.allCases)
    func lookupsLoadRegistryAndReuseCache(backend: TokenServiceBackend) async throws {
        let http = try backend.client()
        let service = backend.service(http)
        #expect(service.token(for: canister) == nil)
        #expect(http.requests.isEmpty)
        #expect(try await service.tokenStandard(for: canister) == .icrc1)
        #expect(try await service.tokenStandard(for: unknown) == nil)
        #expect(try await service.actor(for: unknown) == nil)
        #expect(try await service.actor(for: canister) is ICRC1TokenActor)
        let tokens = try await service.allTokens()
        #expect(service.token(for: canister) == tokens.first { $0.canister == canister })
        #expect(service.token(for: unknown) == nil)
        #expect(try await service.allTokens() == tokens)
        #expect(http.requests.count == backend.registryRequestCount)
    }

    @Test(arguments: TokenServiceBackend.allCases, [0, 1, 2])
    func actorOverloadsUseInjectedClientAndCanister(backend: TokenServiceBackend, overload: Int) async throws {
        let http = try backend.client()
        let service = backend.service(http)
        let actor: (any ICPTokenActor)?
        switch overload {
        case 0: actor = service.actor(for: .icrc1, canister)
        case 1:
            let token = try #require(await service.allTokens().first { $0.canister == canister })
            actor = service.actor(for: token)
        default: actor = try await service.actor(for: canister)
        }
        #expect(try await #require(actor).balance(of: .mainAccount(of: unknown)) == 123)
        let content = try DABMockResponses.envelope(#require(http.lastRequest)).content
        #expect(content.canister_id == canister.bytes)
        #expect(content.method_name == "icrc1_balance_of")
        #expect(http.requests.count == (overload == 0 ? 1 : backend.registryRequestCount + 1))
    }

    @Test(arguments: TokenServiceBackend.allCases)
    func unsupportedActorsDoNotRequestNetwork(backend: TokenServiceBackend) throws {
        let http = try backend.client()
        let service = backend.service(http)
        let token = ICPToken(standard: .ext, canister: canister, name: "Unsupported",
                             decimals: 0, symbol: "EXT", verified: false, logo: nil)
        #expect(service.actor(for: .ext, canister) == nil)
        #expect(service.actor(for: token) == nil)
        #expect(http.requests.isEmpty)
    }

    @Test(arguments: TokenServiceBackend.allCases)
    func balanceKeepsPositiveHoldingsAndPreservesAccount(backend: TokenServiceBackend) async throws {
        let zero = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
        let failed = ICPSystemCanisters.ledger
        let unsupported = ICPPrincipal("r7inp-6aaaa-aaaaa-aaabq-cai")
        let amount = BigUInt(1) << 100
        // DAB additionally includes an unsupported token; Oracle only describes ICRC1/ICP tokens.
        let http = try backend.balanceClient(positive: canister, zero: zero, failed: failed,
                                            unsupported: unsupported, amount: amount)
        let service = backend.service(http)
        let account = try ICPAccount(principal: unknown, subAccountId: Data(repeating: 7, count: 32))
        let holdings = try await service.balance(of: account)
        #expect(holdings.count == 1)
        #expect(holdings.first?.token.canister == canister)
        #expect(holdings.first?.balance == amount)
        let requests = try http.requests.filter {
            try DABMockResponses.envelope($0).content.method_name == "icrc1_balance_of"
        }
        #expect(requests.count == 3)
        for request in requests {
            #expect(try DABMockResponses.envelope(request).content.canister_id != unsupported.bytes)
            let args = try DABMockResponses.arguments(ICRC1.Account.self, from: request)
            #expect(args.owner == account.principal)
            #expect(args.subaccount == account.subAccountId)
        }
    }

    @Test(arguments: TokenServiceBackend.allCases)
    func transactionsRequireCachedToken(backend: TokenServiceBackend) async throws {
        let http = try backend.client()
        let service = backend.service(http)
        let account = ICPAccount.mainAccount(of: unknown)
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await service.transactions(of: account, for: canister)
        }
        #expect(http.requests.isEmpty)
        _ = try await service.allTokens()
        await #expect(throws: DABTokenServiceError.tokenNotFound) {
            _ = try await service.transactions(of: account, for: unknown)
        }
        #expect(http.requests.count == backend.registryRequestCount)
    }

    @Test(arguments: TokenServiceBackend.allCases)
    func transactionsWithoutAnIndexReturnEmptyForBothOverloads(backend: TokenServiceBackend) async throws {
        let http = try backend.client()
        let service = backend.service(http)
        let token = try #require(await service.allTokens().first { $0.canister == canister })
        let account = ICPAccount.mainAccount(of: unknown)
        #expect(try await service.transactions(of: account, for: token).isEmpty)
        #expect(try await service.transactions(of: account, for: canister).isEmpty)
        #expect(http.requests.count == backend.noIndexRequestCount)
        if backend == .dab {
            let content = try DABMockResponses.envelope(#require(http.lastRequest)).content
            #expect(content.method_name == "list_deployed_snses")
            #expect(content.canister_id == ICPSystemCanisters.nns_sns_w.bytes)
        }
    }

    @Test(arguments: TokenServiceBackend.allCases)
    func explorerURLsUseICPAndSNSRootsAndCacheSNSLookup(backend: TokenServiceBackend) async throws {
        let root = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
        let response = NNS_SNS_W.ListDeployedSnsesResponse(instances: [
            .init(root_canister_id: root, governance_canister_id: nil,
                  index_canister_id: nil, swap_canister_id: nil, ledger_canister_id: canister)
        ])
        let http = DABMockResponses.client(queries: [
            "list_deployed_snses": try DABMockResponses.candid(response)
        ])
        let service = backend.service(http)
        #expect(try await service.explorerUrl(tokenCanister: ICPSystemCanisters.ledger,
            transactionIndex: "123")?.absoluteString == "https://dashboard.internetcomputer.org/transaction/123")
        #expect(http.requests.isEmpty)
        #expect(try await service.explorerUrl(tokenCanister: canister,
            transactionIndex: "42")?.absoluteString
            == "https://dashboard.internetcomputer.org/sns/rrkah-fqaaa-aaaaa-aaaaq-cai/transaction/42")
        #expect(try await service.explorerUrl(tokenCanister: unknown, transactionIndex: "42") == nil)
        #expect(http.requests.count == 1)
        #expect(try DABMockResponses.envelope(#require(http.lastRequest)).content.canister_id
                == ICPSystemCanisters.nns_sns_w.bytes)
    }
}
