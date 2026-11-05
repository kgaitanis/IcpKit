import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct DABNftServiceTests {
    private let fixtures = DABNftFixtures()
    private let canister = ICPPrincipal("aaaaa-aa")
    private let user = ICPPrincipal("2vxsx-fae")

    @Test(arguments: ["ext", "ICRC7", "nftorigyn", "icpunks", "c3", "dip721", "dip721v2", "erc721"])
    func mapsCollectionMetadataAndCachesResults(standard: String) async throws {
        let expected: [String: ICPNftStandard] = [
            "ext": .ext, "ICRC7": .icrc7, "nftorigyn": .origynNft, "icpunks": .icPunks,
            "c3": .c3, "dip721": .dip721, "dip721v2": .dip721v2, "erc721": .erc721
        ]
        let http = try fixtures.client(collections: [fixtures.collection(standard: .Text(standard))])
        let service = DABNftService(DABMockResponses.requestClient(http))
        #expect(http.requests.isEmpty)
        let collections = try await service.allCollections()
        #expect(collections.count == 1)
        let collection = try #require(collections.first)
        #expect(collection.standard == expected[standard])
        #expect(collection.canister == canister)
        #expect(collection.name == "Test Collection")
        #expect(collection.description == "Fixture collection")
        #expect(collection.icon == URL(string: "https://example.com/collection.png"))
        let cached = try await service.allCollections()
        #expect(cached.map(\.canister) == collections.map(\.canister))
        #expect(cached.map(\.name) == collections.map(\.name))
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        let content = try DABMockResponses.envelope(request).content
        #expect(content.request_type == "query")
        #expect(content.method_name == "get_all")
        #expect(content.canister_id == DABService.nftRegistry.bytes)
        #expect(request.url.path.hasSuffix("/\(DABService.nftRegistry)/query"))
        #expect(try CandidDeserialiser().decode(#require(content.arg)).isEmpty)
    }

    @Test(arguments: [false, true])
    func emptyOrEntirelyUnsupportedRegistryIsCached(unsupported: Bool) async throws {
        let records = try unsupported ? [fixtures.collection(standard: .Text("unknown"))] : []
        let http = try fixtures.client(collections: records)
        let service = DABNftService(DABMockResponses.requestClient(http))
        #expect(try await service.allCollections().isEmpty)
        #expect(try await service.allCollections().isEmpty)
        #expect(try await service.holdings(user).isEmpty)
        #expect(http.requests.count == 1)
    }

    @Test func missingInvalidAndUnknownStandardsAreSkipped() async throws {
        let http = try fixtures.client(collections: [
            fixtures.collection(),
            fixtures.collection(standard: nil),
            fixtures.collection(standard: .U64(7)),
            fixtures.collection(standard: .Text("unknown"))
        ])
        let service = DABNftService(DABMockResponses.requestClient(http))
        #expect(try await service.allCollections().map(\.standard) == [.icrc7])
        #expect(try await service.allCollections().count == 1)
        #expect(http.requests.count == 1)
    }

    @Test(arguments: [false, true])
    func failedRegistryLoadCanBeRetried(malformed: Bool) async throws {
        let reply = try fixtures.registryReply([fixtures.collection()])
        let attempts = TokenServiceAttemptCounter()
        let http = MockHttpClient { _ in
            if attempts.next() == 1 {
                return malformed
                    ? try TokenServiceTestResponses.reply(Data([0]))
                    : HttpResponse(data: Data("unavailable".utf8), statusCode: 503)
            }
            return try TokenServiceTestResponses.reply(reply)
        }
        let service = DABNftService(DABMockResponses.requestClient(http))
        if malformed {
            await #expect(throws: (any Error).self) { _ = try await service.allCollections() }
        } else {
            await #expect {
                _ = try await service.holdings(user)
            } throws: { error in
                guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
                return code == 503 && message == "unavailable"
            }
        }
        #expect(http.requests.count == 1)
        #expect(try await service.allCollections().count == 1)
        #expect(try await service.allCollections().count == 1)
        #expect(http.requests.count == 2)
    }

    @Test(arguments: [ICPNftStandard.ext, .icrc7, .origynNft, .icPunks, .departuresLabs, .c3, .dip721, .dip721v2, .erc721])
    func actorOverloadsSelectSupportedStandards(standard: ICPNftStandard) throws {
        let http = DABMockResponses.client()
        let service = DABNftService(DABMockResponses.requestClient(http))
        let collection = ICPNftCollection(standard: standard, name: "", description: "", icon: nil, canister: canister)
        let nft = ICPNftDetails(standard: standard, index: .number(42), name: nil,
            imageUrl: try #require(URL(string: "https://example.com/nft.png")), metadata: nil, canister: canister)
        for actor in [service.actor(for: collection), service.actor(for: nft)] {
            switch standard {
            case .ext: #expect(actor is EXTNftActor)
            case .icrc7: #expect(actor is ICRC7NftActor)
            case .origynNft: #expect(actor is OrigynNftActor)
            default: #expect(actor == nil)
            }
        }
        #expect(http.requests.isEmpty)
    }

    @Test func unsupportedDetailsReturnNilWithoutRequest() async throws {
        let http = DABMockResponses.client()
        let service = DABNftService(DABMockResponses.requestClient(http))
        #expect(try await service.nftDetails(.dip721, canister, .number(42)) == nil)
        #expect(http.requests.isEmpty)
    }

    @Test func nftDetailsRoutesToCollectionCanister() async throws {
        let http = DABMockResponses.client(queries: ["icrc7_token_metadata": try fixtures.metadataReply()])
        let service = DABNftService(DABMockResponses.requestClient(http))
        let nft = try #require(await service.nftDetails(.icrc7, canister, .number(42)))
        #expect(nft.standard == .icrc7)
        #expect(nft.canister == canister)
        #expect(nft.index == .number(42))
        #expect(nft.name == "#42")
        #expect(nft.imageUrl == URL(string: "https://example.com/nft.png"))
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        let content = try DABMockResponses.envelope(request).content
        #expect(content.request_type == "query")
        #expect(content.method_name == "icrc7_token_metadata")
        #expect(content.canister_id == canister.bytes)
        #expect(try DABMockResponses.arguments([BigUInt].self, from: request) == [42])
    }

    @Test func nftDetailsPropagatesActorFailure() async throws {
        let http = MockHttpClient { _ in HttpResponse(data: Data("unavailable".utf8), statusCode: 503) }
        let service = DABNftService(DABMockResponses.requestClient(http))
        await #expect {
            _ = try await service.nftDetails(.icrc7, canister, .number(42))
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
        #expect(http.requests.count == 1)
    }

    @Test func holdingsSkipEmptyUnsupportedAndFailedCollectionsAndReuseRegistry() async throws {
        let empty = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
        let failed = ICPPrincipal("ryjl3-tyaaa-aaaaa-aaaba-cai")
        let registry = try fixtures.registryReply([
            fixtures.collection(),
            fixtures.collection(canister: empty),
            fixtures.collection(canister: failed),
            fixtures.collection(canister: user, standard: .Text("dip721"))
        ])
        let metadata = try fixtures.metadataReply()
        let emptyMetadata = try fixtures.metadataReply(empty: true)
        let http = MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            switch content.method_name {
            case "get_all": return try TokenServiceTestResponses.reply(registry)
            case "icrc7_tokens_of":
                if content.canister_id == failed.bytes { return HttpResponse(statusCode: 503) }
                let tokens: [BigUInt] = content.canister_id == empty.bytes ? [] : [42]
                return try TokenServiceTestResponses.reply(DABMockResponses.candid(tokens))
            case "icrc7_token_metadata":
                return try TokenServiceTestResponses.reply(content.canister_id == empty.bytes ? emptyMetadata : metadata)
            default:
                Issue.record("Unexpected method: \(String(describing: content.method_name))")
                return HttpResponse(statusCode: 500)
            }
        }
        let service = DABNftService(DABMockResponses.requestClient(http))
        for _ in 0..<2 {
            let holdings = try await service.holdings(user)
            #expect(holdings.count == 1)
            let holding = try #require(holdings.first)
            #expect(holding.collection.canister == canister)
            #expect(holding.nfts.map(\.index) == [.number(42)])
            #expect(holding.nfts.first?.canister == canister)
        }
        let contents = try http.requests.map { try DABMockResponses.envelope($0).content }
        #expect(contents.filter { $0.method_name == "get_all" }.count == 1)
        #expect(http.requests.count == 11)
        for content in contents where content.method_name == "icrc7_tokens_of" {
            #expect(content.request_type == "query")
            #expect(content.canister_id != user.bytes)
            let args = try CandidDeserialiser().decode(#require(content.arg))
            #expect(args.count == 3)
            let account = try CandidDecoder().decode(ICRC7.Account.self, from: #require(args.first))
            #expect(account.owner == user)
            #expect(account.subaccount == nil)
            #expect(try CandidDecoder().decode(BigUInt?.self, from: args[1]) == nil)
            #expect(try CandidDecoder().decode(BigUInt?.self, from: args[2]) == nil)
        }
    }
}

private struct DABNftFixtures {
    func collection(canister: ICPPrincipal = ICPPrincipal("aaaaa-aa"),
                    standard: DABNft.detail_value? = .Text("ICRC7")) throws -> CandidValue {
        let types: [String: CandidType] = ["Text": .text, "U64": .natural64]
        let detailType = CandidValue.record([
            .text("standard"), try .variant(types, ("Text", .text("ICRC7")))
        ]).candidType
        let details: [CandidValue]
        switch standard {
        case .Text(let value):
            details = [.record([.text("standard"), try .variant(types, ("Text", .text(value)))])]
        case .U64(let value):
            details = [.record([.text("standard"), try .variant(types, ("U64", .natural64(value)))])]
        default: details = []
        }
        return .record([
            "thumbnail": .text("https://example.com/collection.png"),
            "submitter": .principal(canister.bytes),
            "name": .text("Test Collection"),
            "frontend": .option(.text),
            "description": .text("Fixture collection"),
            "last_updated_at": .natural64(0),
            "last_updated_by": .principal(canister.bytes),
            "details": .vector(try CandidVector(detailType, details)),
            "principal_id": .principal(canister.bytes)
        ])
    }

    func registryReply(_ collections: [CandidValue]) throws -> Data {
        let type = try collection().candidType
        return try CandidSerialiser().encode([.vector(CandidVector(type, collections))])
    }

    func client(collections: [CandidValue]) throws -> MockHttpClient {
        DABMockResponses.client(queries: ["get_all": try registryReply(collections)])
    }

    func metadataReply(empty: Bool = false) throws -> Data {
        let metadata: [[CandidTuple2<String, ICRC7.Value>]?] = empty ? [] : [
            [.init("image", .Text("https://example.com/nft.png"))]
        ]
        return try DABMockResponses.candid(metadata)
    }
}
