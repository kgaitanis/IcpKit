import Foundation
import Testing
import IcpKit
@testable import DAB

/// Read-only mainnet compatibility checks. Run with the IcpKit-Integration scheme.
/// These deliberately fail on unavailable canisters or incompatible responses.
@Suite(.serialized, .timeLimit(.minutes(2)))
struct DABIntegrationTests {
    @Test func tokenRegistryReturnsUsableTokensAndCachesThem() async throws {
        let service = DABTokenService()
        let tokens = try await service.allTokens()
        // The service adds ICP itself, so ICP alone does not prove the registry works.
        #expect(tokens.contains { $0.canister != ICPSystemCanisters.ledger },
                "DAB token registry returned no non-ICP tokens")
        let icp = try #require(tokens.first { $0.canister == ICPSystemCanisters.ledger })
        #expect(icp.symbol == "ICP")
        #expect(icp.decimals == 8)
        for token in tokens {
            #expect(!token.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "Missing name for \(token.canister)")
            #expect(!token.symbol.isEmpty, "Missing symbol for \(token.canister)")
            #expect(service.token(for: token.canister) != nil)
        }
        #expect(try await service.allTokens() == tokens)
    }

    @Test func nftRegistryReturnsNamedCollectionsAndCachesThem() async throws {
        let service = DABNftService()
        let collections = try await service.allCollections()
        try #require(!collections.isEmpty, "DAB NFT registry returned no supported collections")
        #expect(Set(collections.map(\.canister)).count == collections.count,
                "DAB NFT registry returned duplicate collection canisters")
        for collection in collections {
            #expect(!collection.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "Missing collection name for \(collection.canister)")
        }
        let cached = try await service.allCollections()
        #expect(cached.map(\.canister) == collections.map(\.canister))
        #expect(cached.map(\.name) == collections.map(\.name))
    }

    @Test func oracleCountAndFirstPageDecodeSuccessfully() async throws {
        let service = ICRC1Oracle.Service(DABService.icrc1Oracle, client: ICPRequestClient())
        let count = try await service.count_icrc1_canisters()
        try #require(count > 0, "ICRC-1 oracle registry is empty")
        // Query the generated service directly: TokenOracle.allTokens() suppresses page errors.
        // Do not compare the exact count across requests; the registry can change between them.
        let page = try await service.get_icrc1_paginated(0, 10)
        try #require(!page.isEmpty, "Oracle reported tokens but returned an empty first page")
        #expect(page.count <= 10, "Oracle exceeded the requested page size")
        let ledgers = try page.map { try ICPPrincipal($0.ledger) }
        #expect(Set(ledgers).count == ledgers.count, "Oracle page contains duplicate ledger IDs")
        for token in page {
            if let index = token.index {
                _ = try ICPPrincipal(index)
            }
        }
    }

    @Test func icpLedgerMetadataAgreesWithICRC1Endpoints() async throws {
        let client = ICPRequestClient()
        let service = ICRC1.Service(ICPSystemCanisters.ledger, client: client)
        let actor = try #require(DABTokenService(client).actor(for: .icrc1, ICPSystemCanisters.ledger))
        let metadata = try await actor.metaData()
        #expect(metadata.symbol == "ICP")
        #expect(metadata.decimals == 8)
        #expect(metadata.name == (try await service.icrc1_name()))
        #expect(metadata.symbol == (try await service.icrc1_symbol()))
        #expect(metadata.decimals == Int(try await service.icrc1_decimals()))
        #expect(metadata.fee == (try await actor.fee()))
        #expect(try #require(metadata.totalSupply) > 0)
    }

    @Test func icpIndexIdentifiesLedgerAndReturnsGenesisBlock() async throws {
        let service = ICPIndex.Service(ICPSystemCanisters.index, client: ICPRequestClient())
        #expect(try await service.ledger_id() == ICPSystemCanisters.ledger)
        // A fixed historical block avoids relying on a funded wallet or changing history.
        let response = try await service.get_blocks(.init(start: 0, length: 1))
        #expect(response.chain_length > 0)
        try #require(response.blocks.count == 1, "ICP index did not return the requested genesis block")
        #expect(!response.blocks[0].isEmpty, "ICP index returned an empty encoded block")
    }
}
