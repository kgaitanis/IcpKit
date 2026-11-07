import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct ICRC7NftActorTests {
    @Test func serviceResolvesActorForCollectionAndNft() throws {
        let http = DABMockResponses.client()
        let service = DABNftService(DABMockResponses.requestClient(http))
        let collection = ICPNftCollection(standard: .icrc7, name: "", description: "", icon: nil, canister: canister)
        let nft = ICPNftDetails(standard: .icrc7, index: .number(42), name: nil,
            imageUrl: try #require(URL(string: "https://example.com/nft.png")), metadata: nil, canister: canister)
        #expect(service.actor(for: collection) is ICRC7NftActor)
        #expect(service.actor(for: nft) is ICRC7NftActor)
        #expect(http.requests.isEmpty)
    }

    private let canister = ICPPrincipal("aaaaa-aa")
    private let user = ICPPrincipal("2vxsx-fae")

    @Test(arguments: [BigUInt(0), 42, BigUInt(1) << 100])
    func nftDetailsMapsMetadataAndPreservesIndex(index: BigUInt) async throws {
        let http = DABMockResponses.client(queries: [
            "icrc7_token_metadata": try metadataReply([[("image", "Text", .text("https://example.com/nft.png"))]])
        ])
        let canisterText: String = "aaaaa-aa"
        let actor = try ICRC7NftActor(canisterText, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.number(index))

        #expect(actor.standard == .icrc7)
        #expect(nft.standard == .icrc7)
        #expect(nft.canister == canister)
        #expect(nft.index == .number(index))
        #expect(nft.name == "#\(index)")
        #expect(nft.imageUrl == URL(string: "https://example.com/nft.png"))
        #expect(nft.metadata == .dictionary([:]))
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        try assertQuery(request, method: "icrc7_token_metadata")
        #expect(try DABMockResponses.arguments([BigUInt].self, from: request) == [index])
    }

    @Test(arguments: [false, true], [false, true])
    func listsTokensAndRequestsTheirMetadata(userOnly: Bool, empty: Bool) async throws {
        let ids: [BigUInt] = empty ? [] : [99, 7]
        let fields: [[Field]?] = empty ? [] : [
            [("image", "Text", .text("https://example.com/99.png"))],
            [("image", "Text", .text("https://example.com/7.png"))]
        ]
        let method = userOnly ? "icrc7_tokens_of" : "icrc7_tokens"
        let http = DABMockResponses.client(queries: [
            method: try DABMockResponses.candid(ids),
            "icrc7_token_metadata": try metadataReply(fields)
        ])
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        let nfts = try await userOnly ? actor.userTokens(user) : actor.allNfts()

        #expect(nfts.map(\.index) == ids.map { .number($0) })
        #expect(nfts.map(\.name) == (empty ? [] : ["#99", "#7"]))
        #expect(nfts.map(\.imageUrl.absoluteString) == (empty ? [] : [
            "https://example.com/99.png", "https://example.com/7.png"
        ]))
        #expect(nfts.allSatisfy { $0.standard == .icrc7 && $0.canister == canister })
        #expect(http.requests.count == 2)
        let first = try #require(http.requests.first)
        try assertQuery(first, method: method)
        let args = try CandidDeserialiser().decode(#require(DABMockResponses.envelope(first).content.arg))
        #expect(args.count == (userOnly ? 3 : 2))
        if userOnly {
            let account = try CandidDecoder().decode(ICRC7.Account.self, from: args[0])
            #expect(account.owner == user)
            #expect(account.subaccount == nil)
        }
        for arg in args.suffix(2) {
            #expect(try CandidDecoder().decode(BigUInt?.self, from: arg) == nil)
        }
        let last = try #require(http.lastRequest)
        try assertQuery(last, method: "icrc7_token_metadata")
        #expect(try DABMockResponses.arguments([BigUInt].self, from: last) == ids)
    }

    @Test func metadataConvertsValuesAndKeepsLastDuplicate() async throws {
        let nested = try CandidEncoder().encode(ICRC7.Value.Array([.Text("nested")]))
        let map = try CandidEncoder().encode(ICRC7.Value.Map([.init("key", .Nat(9))]))
        guard case .variant(let arrayValue) = nested, case .variant(let mapValue) = map else {
            Issue.record("Expected variant fixtures")
            return
        }
        let fields: [Field] = [
            ("image", "Text", .text("https://example.com/nft.png")),
            ("label", "Text", .text("first")),
            ("label", "Text", .text("last")),
            ("signed", "Int", .integer(-42)),
            ("large", "Nat", .natural(BigUInt(1) << 100)),
            ("bytes", "Blob", .blob(Data([0, 255]))),
            ("array", "Array", arrayValue.value),
            ("map", "Map", mapValue.value)
        ]
        let http = DABMockResponses.client(queries: ["icrc7_token_metadata": try metadataReply([fields])])
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.number(42))
        #expect(nft.metadata == .dictionary([
            "label": .string("last"), "signed": .number(-42),
            "large": .number(BigInt(1) << 100), "bytes": .data(Data([0, 255])),
            "array": .array([.string("nested")]), "map": .dictionary(["key": .number(9)])
        ]))
    }

    @Test func emptyMetadataResponseMeansNftNotFound() async throws {
        let http = DABMockResponses.client(queries: ["icrc7_token_metadata": try metadataReply([])])
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftActorError.nftNotFound) { try await actor.nftDetails(.number(42)) }
    }

    @Test(arguments: ["absent", "empty", "missingImage", "wrongType", "invalidURL"])
    func rejectsInvalidMetadata(kind: String) async throws {
        let fields: [Field]?
        switch kind {
        case "absent": fields = nil
        case "empty": fields = []
        case "missingImage": fields = [("name", "Text", .text("NFT"))]
        case "wrongType": fields = [("image", "Nat", .natural(42))]
        default: fields = [("image", "Text", .text("https://["))]
        }
        let http = DABMockResponses.client(queries: ["icrc7_token_metadata": try metadataReply([fields])])
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftActorError.invalidMetaData) { try await actor.nftDetails(.number(42)) }
    }

    @Test func stringIndexIsRejectedWithoutRequest() async throws {
        let http = DABMockResponses.client()
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftDetails.Index.IndexError.notANumber) {
            try await actor.nftDetails(.string("42"))
        }
        #expect(http.requests.isEmpty)
    }

    @Test(arguments: ["details", "all", "user"])
    func propagatesHTTPFailure(operation: String) async throws {
        let http = MockHttpClient(response: HttpResponse(data: Data("unavailable".utf8), statusCode: 503))
        let actor = ICRC7NftActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            switch operation {
            case "all": _ = try await actor.allNfts()
            case "user": _ = try await actor.userTokens(user)
            default: _ = try await actor.nftDetails(.number(42))
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

    private typealias Field = (key: String, variant: String, value: CandidValue)

    private func metadataReply(_ metadata: [[Field]?]) throws -> Data {
        // Declare a shared variant type, including for empty and absent metadata.
        var types: [String: CandidType] = ["Text": .text]
        for fields in metadata {
            for field in fields ?? [] { types[field.variant] = field.value.candidType }
        }
        let fieldType = CandidValue.record([
            .text("image"), try .variant(types, ("Text", .text("image")))
        ]).candidType
        let metadataType = CandidType.vector(fieldType)
        let values = try metadata.map { fields -> CandidValue in
            guard let fields else { return .option(metadataType) }
            let entries = try fields.map { field in
                CandidValue.record([.text(field.key), try .variant(types, (field.variant, field.value))])
            }
            return .option(.vector(try CandidVector(fieldType, entries)))
        }
        return try CandidSerialiser().encode([.vector(CandidVector(.option(metadataType), values))])
    }
}
