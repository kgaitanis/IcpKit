import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct OrigynNftActorTests {
    @Test func serviceResolvesActorForCollectionAndNft() throws {
        let http = DABMockResponses.client()
        let service = DABNftService(DABMockResponses.requestClient(http))
        let collection = ICPNftCollection(standard: .origynNft, name: "", description: "", icon: nil, canister: canister)
        let nft = ICPNftDetails(standard: .origynNft, index: .string("token-42"), name: nil,
            imageUrl: try #require(URL(string: "https://example.com/nft.png")), metadata: nil, canister: canister)
        #expect(service.actor(for: collection) is OrigynNftActor)
        #expect(service.actor(for: nft) is OrigynNftActor)
        #expect(http.requests.isEmpty)
    }

    private let canister = ICPPrincipal("aaaaa-aa")
    private let user = ICPPrincipal("2vxsx-fae")
    private let fixtures = OrigynNftFixtures()

    @Test(arguments: ["canister", "collection"])
    func nftDetailsMapsPreviewAndLibraryMetadata(locationType: String) async throws {
        let metadata = fixtures.metadata(libraries: [
            fixtures.library(locationType: locationType)
        ])
        let http = DABMockResponses.client(queries: ["nft_origyn": try fixtures.nftReply(metadata)])
        let canisterText: String = "aaaaa-aa"
        let actor = try OrigynNftActor(canisterText, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.string("token-42"))

        #expect(actor.standard == .origynNft)
        #expect(nft.standard == .origynNft)
        #expect(nft.canister == canister)
        #expect(nft.index == .string("token-42"))
        #expect(nft.name == "Display name")
        #expect(nft.imageUrl.absoluteString == "https://aaaaa-aa.raw.icp0.io/assets/preview.png")
        #expect(nft.metadata == .dictionary([
            "assets": .array([.dictionary([
                "id": .string("preview"), "name": .string("Preview"),
                "contentType": .string("image/png"), "contentHash": .string("abc123"),
                "size": .number(1024), "sort": .number(2),
                "url": .url(try #require(URL(string: "https://aaaaa-aa.raw.icp0.io/assets/preview.png")))
            ])]),
            "properties": .dictionary([:])
        ]))
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        try assertQuery(request, method: "nft_origyn")
        #expect(try DABMockResponses.arguments(String.self, from: request) == "token-42")
    }

    @Test func librariesAreSortedAndPrivateOrMalformedEntriesAreIgnored() async throws {
        let metadata = fixtures.metadata(libraries: [
            fixtures.library(),
            fixtures.library(id: "private", read: "private"),
            .Text("malformed"),
            fixtures.library(id: "first", sort: 1),
            fixtures.library(id: "external", locationType: "unknown", sort: 3)
        ])
        let http = DABMockResponses.client(queries: ["nft_origyn": try fixtures.nftReply(metadata)])
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.string("token-42"))
        guard case .dictionary(let metadata) = nft.metadata,
              case .array(let assets) = metadata["assets"] else {
            Issue.record("Expected asset metadata")
            return
        }
        let dictionaries = assets.map { asset -> [String: ICPNftMetadataItem] in
            guard case .dictionary(let fields) = asset else {
                Issue.record("Expected an asset dictionary")
                return [:]
            }
            return fields
        }
        #expect(dictionaries.map { $0["id"] } == [.string("first"), .string("preview"), .string("external")])
        #expect(dictionaries[2]["url"] == nil)
    }

    @Test func customPropertiesConvertValuesAndKeepLastDuplicate() async throws {
        let properties: [OrigynNFT.PropertyShared] = [
            fixtures.property("color", .Text("red")),
            fixtures.property("color", .Text("blue")),
            fixtures.property("count", .Nat(99)),
            fixtures.property("signed", .Int(-7)),
            fixtures.property("enabled", .Bool(true)),
            fixtures.property("bytes", .Blob(Data([0, 255]))),
            fixtures.property("list", .Array([.Text("one"), .Text("two")])),
            fixtures.property("nested", .Class([fixtures.property("key", .Text("value"))]))
        ]
        let metadata = fixtures.metadata(apps: [
            .Text("ignored"), .Class([fixtures.property("data", .Text("ignored"))]),
            .Class([fixtures.property("data", .Class(properties))])
        ])
        let http = DABMockResponses.client(queries: ["nft_origyn": try fixtures.nftReply(metadata)])
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.string("token-42"))
        guard case .dictionary(let fields) = nft.metadata else {
            Issue.record("Expected metadata dictionary")
            return
        }
        #expect(fields["properties"] == .dictionary([
            "color": .string("blue"), "count": .string("99"), "signed": .string("-7"),
            "enabled": .string("true"), "bytes": .string("00ff"),
            "list": .string("[one, two]"), "nested": .string("[key: value]")
        ]))
    }

    @Test(arguments: ["notClass", "missingId", "wrongId", "missingPreview", "wrongPreview",
                      "missingLibrary", "unknownPreview", "privatePreview", "invalidLibrary", "unknownLocation"])
    func rejectsInvalidMetadata(kind: String) async throws {
        var properties = fixtures.properties()
        switch kind {
        case "missingId": properties.removeAll { $0.name == "id" }
        case "wrongId": properties = properties.filter { $0.name != "id" } + [fixtures.property("id", .Nat(42))]
        case "missingPreview": properties.removeAll { $0.name == "preview_asset" }
        case "wrongPreview":
            properties = properties.filter { $0.name != "preview_asset" } + [fixtures.property("preview_asset", .Nat(42))]
        case "missingLibrary": properties.removeAll { $0.name == "library" }
        case "unknownPreview":
            properties = properties.filter { $0.name != "preview_asset" } + [fixtures.property("preview_asset", .Text("missing"))]
        case "privatePreview":
            properties = fixtures.properties(libraries: [fixtures.library(read: "private")])
        case "invalidLibrary":
            properties = fixtures.properties(libraries: [.Text("invalid")])
        case "unknownLocation":
            properties = fixtures.properties(libraries: [fixtures.library(locationType: "unknown")])
        default: break
        }
        let metadata: OrigynNFT.CandyShared = kind == "notClass" ? .Text("invalid") : .Class(properties)
        let http = DABMockResponses.client(queries: ["nft_origyn": try fixtures.nftReply(metadata)])
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftActorError.invalidMetaData) { try await actor.nftDetails(.string("token-42")) }
    }

    @Test(arguments: [false, true], [false, true])
    func listsTokensAndFetchesBatchInOrder(userOnly: Bool, empty: Bool) async throws {
        let ids = empty ? [] : ["second", "first"]
        let method = userOnly ? "balance_of_nft_origyn" : "collection_nft_origyn"
        let http = DABMockResponses.client(queries: [
            method: try userOnly ? fixtures.balanceReply(ids) : fixtures.collectionReply(ids),
            "nft_batch_origyn": try fixtures.batchReply(ids.map { fixtures.metadata(name: $0) })
        ])
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        let nfts = try await userOnly ? actor.userTokens(user) : actor.allNfts()
        #expect(nfts.map(\.index) == ids.map { .string($0) })
        #expect(nfts.map(\.name) == ids.map { Optional($0) })
        #expect(nfts.allSatisfy { $0.standard == .origynNft && $0.canister == canister })
        #expect(nfts.allSatisfy { $0.imageUrl.absoluteString == "https://aaaaa-aa.raw.icp0.io/assets/preview.png" })
        #expect(http.requests.count == 2)
        let first = try #require(http.requests.first)
        try assertQuery(first, method: method)
        if userOnly {
            let account = try DABMockResponses.arguments(OrigynNFT.Account.self, from: first)
            guard case .principal(let owner) = account else {
                Issue.record("Expected a principal account")
                return
            }
            #expect(owner == user)
        } else {
            let fields = try DABMockResponses.arguments([CandidTuple3<String, BigUInt?, BigUInt?>]?.self, from: first)
            #expect(fields == nil)
        }
        let last = try #require(http.lastRequest)
        try assertQuery(last, method: "nft_batch_origyn")
        #expect(try DABMockResponses.arguments([String].self, from: last) == ids)
    }

    @Test func absentCollectionTokenIdsReturnEmptyWithoutBatchRequest() async throws {
        let http = DABMockResponses.client(queries: ["collection_nft_origyn": try fixtures.collectionReply(nil)])
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        #expect(try await actor.allNfts().isEmpty)
        #expect(http.requests.count == 1)
        try assertQuery(#require(http.lastRequest), method: "collection_nft_origyn")
    }

    @Test(arguments: ["details", "all", "user", "allBatch", "userBatch"])
    func propagatesCanisterErrors(operation: String) async throws {
        let error = OrigynNFT.OrigynError(text: "missing NFT", error: .token_not_found, number: 404, flag_point: "fixture")
        var queries: [String: Data] = [:]
        switch operation {
        case "details": queries["nft_origyn"] = try DABMockResponses.candid(OrigynNFT.NFTInfoResult.err(error))
        case "all": queries["collection_nft_origyn"] = try DABMockResponses.candid(OrigynNFT.CollectionResult.err(error))
        case "user": queries["balance_of_nft_origyn"] = try DABMockResponses.candid(OrigynNFT.BalanceResult.err(error))
        default:
            queries["collection_nft_origyn"] = try fixtures.collectionReply(["token-42"])
            queries["balance_of_nft_origyn"] = try fixtures.balanceReply(["token-42"])
            queries["nft_batch_origyn"] = try DABMockResponses.candid([OrigynNFT.NFTInfoResult.err(error)])
        }
        let http = DABMockResponses.client(queries: queries)
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            switch operation {
            case "all", "allBatch": _ = try await actor.allNfts()
            case "user", "userBatch": _ = try await actor.userTokens(user)
            default: _ = try await actor.nftDetails(.string("token-42"))
            }
        } throws: { error in
            guard let error = error as? OrigynNFT.OrigynError,
                  case .token_not_found = error.error else { return false }
            return error.text == "missing NFT" && error.number == 404 && error.flag_point == "fixture"
        }
        #expect(http.requests.count == (operation.hasSuffix("Batch") ? 2 : 1))
    }

    @Test func rejectsNumericIndexWithoutRequest() async throws {
        let http = DABMockResponses.client()
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftDetails.Index.IndexError.notAString) {
            try await actor.nftDetails(.number(42))
        }
        #expect(http.requests.isEmpty)
    }

    @Test(arguments: ["details", "all", "user"])
    func propagatesHTTPFailure(operation: String) async throws {
        let http = MockHttpClient(response: HttpResponse(data: Data("unavailable".utf8), statusCode: 503))
        let actor = OrigynNftActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            switch operation {
            case "all": _ = try await actor.allNfts()
            case "user": _ = try await actor.userTokens(user)
            default: _ = try await actor.nftDetails(.string("token-42"))
            }
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
        #expect(http.requests.count == 1)
    }

    private func assertQuery(_ request: HttpRequest, method: String,
                             sourceLocation: SourceLocation = #_sourceLocation) throws {
        let content = try DABMockResponses.envelope(request).content
        #expect(content.request_type == "query", sourceLocation: sourceLocation)
        #expect(content.method_name == method, sourceLocation: sourceLocation)
        #expect(content.canister_id == canister.bytes, sourceLocation: sourceLocation)
        #expect(request.url.path.hasSuffix("/aaaaa-aa/query"), sourceLocation: sourceLocation)
    }
}

private struct OrigynNftFixtures {
    func property(_ name: String, _ value: OrigynNFT.CandyShared) -> OrigynNFT.PropertyShared {
        .init(value: value, name: name, immutable: false)
    }

    func library(id: String = "preview", locationType: String = "canister",
                 read: String = "public", sort: BigUInt = 2) -> OrigynNFT.CandyShared {
        .Class([
            property("library_id", .Text(id)), property("title", .Text("Preview")),
            property("location_type", .Text(locationType)), property("location", .Text("assets/preview.png")),
            property("content_type", .Text("image/png")), property("content_hash", .Text("abc123")),
            property("size", .Nat(1024)), property("sort", .Nat(sort)), property("read", .Text(read))
        ])
    }

    func properties(name: String = "Display name", libraries: [OrigynNFT.CandyShared]? = nil,
                    apps: [OrigynNFT.CandyShared]? = nil) -> [OrigynNFT.PropertyShared] {
        var fields = [
            property("id", .Text(name)), property("preview_asset", .Text("preview")),
            property("library", .Array(libraries ?? [library()]))
        ]
        if let apps { fields.append(property("__apps", .Array(apps))) }
        return fields
    }

    func metadata(name: String = "Display name", libraries: [OrigynNFT.CandyShared]? = nil,
                  apps: [OrigynNFT.CandyShared]? = nil) -> OrigynNFT.CandyShared {
        .Class(properties(name: name, libraries: libraries, apps: apps))
    }

    func collectionReply(_ ids: [String]?) throws -> Data {
        // Wrap the encoded record directly: encoding the enum re-wraps its optional fields.
        let info = try CandidEncoder().encode(OrigynNFT.CollectionInfo(
            multi_canister_count: nil, managers: nil, owner: nil, metadata: nil,
            logo: nil, name: nil, network: nil, created_at: nil, fields: nil, upgraded_at: nil,
            token_ids_count: nil, available_space: nil, multi_canister: nil, token_ids: ids,
            transaction_count: nil, unique_holders: nil, total_supply: nil, symbol: nil, allocated_storage: nil
        ))
        return CandidSerialiser().encode([try .variant(["ok": info.candidType], ("ok", info))])
    }

    func balanceReply(_ ids: [String]) throws -> Data {
        try DABMockResponses.candid(OrigynNFT.BalanceResult.ok(.init(
            nfts: ids, offers: [], sales: [], stake: [], multi_canister: nil, escrow: []
        )))
    }

    func nftReply(_ metadata: OrigynNFT.CandyShared) throws -> Data {
        CandidSerialiser().encode([try nftResult(metadata)])
    }

    func batchReply(_ metadata: [OrigynNFT.CandyShared]) throws -> Data {
        let type = try nftResult(self.metadata()).candidType
        return try CandidSerialiser().encode([.vector(CandidVector(type, metadata.map(nftResult)))])
    }

    private func nftResult(_ metadata: OrigynNFT.CandyShared) throws -> CandidValue {
        let info = CandidValue.record(["metadata": try candy(metadata, depth: 7), "current_sale": .option(CandidType.null)])
        return try .variant(["ok": info.candidType], ("ok", info))
    }

    // A finite wire schema gives every heterogeneous Candy vector a shared variant type.
    // Seven levels accommodate the nested application properties used by these fixtures.
    private func candyTypes(_ depth: Int) -> [String: CandidType] {
        var types: [String: CandidType] = [
            "Text": .text, "Nat": .natural, "Int": .integer, "Bool": .bool, "Blob": .blob
        ]
        if depth > 0 {
            let child = CandidType.variant(candyTypes(depth - 1).map { CandidKeyedType($0.key, $0.value) })
            types["Array"] = .vector(child)
            types["Class"] = .vector(.record([
                CandidKeyedType("name", .text), CandidKeyedType("immutable", .bool), CandidKeyedType("value", child)
            ]))
        }
        return types
    }

    private func candy(_ value: OrigynNFT.CandyShared, depth: Int) throws -> CandidValue {
        let types = candyTypes(depth)
        let payload: (String, CandidValue)
        switch value {
        case .Text(let value): payload = ("Text", .text(value))
        case .Nat(let value): payload = ("Nat", .natural(value))
        case .Int(let value): payload = ("Int", .integer(value))
        case .Bool(let value): payload = ("Bool", .bool(value))
        case .Blob(let value): payload = ("Blob", .blob(value))
        case .Array(let values):
            guard depth > 0, case .vector(let childType) = types["Array"] else { throw FixtureError.unsupportedCandy }
            payload = ("Array", .vector(try CandidVector(childType, values.map { try candy($0, depth: depth - 1) })))
        case .Class(let properties):
            guard depth > 0, case .vector(let propertyType) = types["Class"] else { throw FixtureError.unsupportedCandy }
            let values = try properties.map { property in
                CandidValue.record([
                    "name": .text(property.name), "immutable": .bool(property.immutable),
                    "value": try candy(property.value, depth: depth - 1)
                ])
            }
            payload = ("Class", .vector(try CandidVector(propertyType, values)))
        default: throw FixtureError.unsupportedCandy
        }
        return try .variant(types, payload)
    }

    private enum FixtureError: Error { case unsupportedCandy }
}
