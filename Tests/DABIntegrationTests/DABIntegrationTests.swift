import Foundation
import Testing
import Candid
@testable import IcpKit
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

    @Test func icpLedgerAccountBalanceDecodesWithoutRequiringFunds() async throws {
        let client = ICPRequestClient(ReadOnlyIntegrationHttpClient())
        let account = ICPAccount.mainAccount(of: try ICPPrincipal("2vxsx-fae"))
        // Any UInt64 balance, including zero, is valid. Successful decoding is the contract;
        // comparing two requests or requiring funds would depend on mutable account state.
        _ = try await ICPLedgerCanister.accountBalance(of: account, client)
    }

    @Test func icpReadStateReturnsCertifiedTime() async throws {
        let client = ICPRequestClient(ReadOnlyIntegrationHttpClient())
        let started = Date.now
        // The default mainnet root key keeps certificate signature verification enabled.
        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger)
        let finished = Date.now
        let encodedTime = try #require(response.rawValueForPath(endingWith: "time"))
        let nanoseconds: UInt64 = try Leb128.decodeUnsigned(encodedTime)
        let certifiedTime = Date(timeIntervalSince1970: Double(nanoseconds) / 1_000_000_000)
        // Allow certificate caching and modest clock skew; include the whole request/retry
        // interval instead of requiring a response less than ten seconds old at completion.
        #expect(certifiedTime >= started.addingTimeInterval(-300), "Certified time is stale")
        #expect(certifiedTime <= finished.addingTimeInterval(300), "Certified time is in the future")
    }

    @Test func icpLedgerQueryBlockReturnsHistoricalTransfer() async throws {
        let client = ICPRequestClient(ReadOnlyIntegrationHttpClient())
        // Historical block contents are immutable, even when moved to an archive canister.
        let block = try await ICPLedgerCanister.queryBlock(index: 13309698, client)
        #expect(block.timestamp == 1723103842536019792)
        #expect(block.transaction.createdNanos == 1723103842536019792)
        #expect(block.transaction.memo == 0)
        #expect(block.parentHash == Data.fromHex("7f944c23b83cc7d5457b6503f95430cb751f8cfe561374470e672c70fb850342"))
        guard case .transfer(let from, let to, let amount, let fee, _) = block.transaction.operation else {
            Issue.record("Historical ledger block is not a transfer")
            return
        }
        #expect(from == Data.fromHex("07537100d2fb357209a2283d6c5cb588ef7ee09db32fb7cc6f6241e44b155e4c"))
        #expect(to == Data.fromHex("57271f92125bdfd4fe0605f2e22c3ad549fc27cf2e85bae080645a5b516154ec"))
        #expect(amount == 190612587)
        #expect(fee == 10000)
    }

    @Test func icpGeneratedLedgerResolvesHistoricalBlockRange() async throws {
        let client = ICPRequestClient(ReadOnlyIntegrationHttpClient())
        let ledger = LedgerCanister.Service(ICPSystemCanisters.ledger, client: client)
        let start: UInt64 = 11268933
        let length: UInt64 = 3
        let end = start + length
        let response = try await ledger.query_blocks(.init(start: start, length: length))
        #expect(response.chain_length >= end)
        var returnedIndices = Set<UInt64>()

        // Accept direct blocks, archive callbacks, or a mixture as archival boundaries move.
        if !response.blocks.isEmpty {
            try #require(response.first_block_index >= start && response.first_block_index < end)
            try #require(UInt64(response.blocks.count) <= end - response.first_block_index)
            for (offset, block) in response.blocks.enumerated() {
                #expect(returnedIndices.insert(response.first_block_index + UInt64(offset)).inserted)
                #expect(block.timestamp.timestamp_nanos > 0)
                #expect(block.parent_hash?.count == 32)
            }
        }
        for archive in response.archived_blocks {
            try #require(archive.start >= start && archive.start < end)
            try #require(archive.length > 0 && archive.length <= end - archive.start)
            let result = try await archive.callback.callMethod(
                .init(start: archive.start, length: archive.length), client)
            guard case .Ok(let range) = result else {
                Issue.record("Ledger archive rejected a known historical range")
                return
            }
            try #require(UInt64(range.blocks.count) == archive.length,
                         "Archive did not return the requested historical blocks")
            for (offset, block) in range.blocks.enumerated() {
                #expect(returnedIndices.insert(archive.start + UInt64(offset)).inserted,
                        "Ledger returned overlapping block ranges")
                #expect(block.timestamp.timestamp_nanos > 0)
                #expect(block.parent_hash?.count == 32)
            }
        }
        #expect(returnedIndices == Set(start..<end), "Ledger response has missing historical blocks")
    }
}

// Only the migrated read-only checks use this transport. Never retry an update submission.
private final class ReadOnlyIntegrationHttpClient: HttpClient {
    private let client = UrlSessionHttpClient()

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        guard ["query", "read_state"].contains(request.url.lastPathComponent) else {
            throw URLError(.unsupportedURL)
        }
        let boundedRequest = HttpRequest(method: request.method, url: request.url, body: request.body,
                                         headers: request.headers, timeout: min(request.timeout, 10))
        var attempt = 0
        while true {
            try Task.checkCancellation()
            attempt += 1
            do {
                let response = try await client.fetch(boundedRequest)
                // Return the final failure so ICPRequestClient reports its status and body.
                guard attempt < 3, [408, 429, 502, 503, 504].contains(response.statusCode) else {
                    return response
                }
            } catch let error as URLError {
                guard attempt < 3,
                      [.timedOut, .networkConnectionLost, .cannotConnectToHost,
                       .cannotFindHost, .dnsLookupFailed].contains(error.code) else {
                    throw error
                }
            }
            // Cancellation, certificate errors, Candid errors and assertions are never retried.
            try await Task.sleep(for: .seconds(attempt))
        }
    }
}
