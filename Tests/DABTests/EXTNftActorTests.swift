import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct EXTNftActorTests {
    @Test func serviceResolvesActorForCollectionAndNft() throws {
        let http = DABMockResponses.client()
        let service = DABNftService(DABMockResponses.requestClient(http))
        let collection = ICPNftCollection(standard: .ext, name: "", description: "", icon: nil, canister: canister)
        let nft = ICPNftDetails(standard: .ext, index: .number(42), name: nil,
            imageUrl: try #require(URL(string: "https://example.com/nft.png")), metadata: nil, canister: canister)
        #expect(service.actor(for: collection) is EXTNftActor)
        #expect(service.actor(for: nft) is EXTNftActor)
        #expect(http.requests.isEmpty)
    }

    private let canister = ICPPrincipal("rrkah-fqaaa-aaaaa-aaaaq-cai")
    private let user = ICPPrincipal("2vxsx-fae")

    @Test(arguments: [UInt32(0), 42, UInt32.max])
    func nftDetailsEncodesTokenIdentifierAndBuildsThumbnail(index: UInt32) async throws {
        let http = DABMockResponses.client(queries: [
            "metadata": try DABMockResponses.candid(EXT.Result_4.ok(.nonfungible(metadata: nil)))
        ])
        let canisterText: String = "rrkah-fqaaa-aaaaa-aaaaq-cai"
        let actor = try EXTNftActor(canisterText, DABMockResponses.requestClient(http))
        let nft = try await actor.nftDetails(.number(BigUInt(index)))

        #expect(actor.standard == .ext)
        #expect(nft.standard == .ext)
        #expect(nft.canister == canister)
        #expect(nft.index == .number(BigUInt(index)))
        #expect(nft.name == "#\(index)")
        #expect(nft.metadata == nil)
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        try assertQuery(request, method: "metadata")
        let tokenId = try DABMockResponses.arguments(String.self, from: request)
        // Independent byte fixtures catch prefix, canister and endianness regressions.
        let suffix: [UInt8] = index == 0 ? [0, 0, 0, 0] : index == 42 ? [0, 0, 0, 42] : [255, 255, 255, 255]
        #expect(try ICPPrincipal(tokenId).bytes == Data([
            10, 116, 105, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1
        ] + suffix))
        #expect(nft.imageUrl.absoluteString ==
                "https://rrkah-fqaaa-aaaaa-aaaaq-cai.raw.icp0.io/?type=thumbnail&tokenid=\(tokenId)")
    }

    @Test(arguments: ["absent", "binary", "text", "json", "jsonWithoutThumbnail", "invalidJSON"])
    func decodesMetadataFormats(kind: String) async throws {
        let data: Data?
        let expected: ICPNftMetadataItem?
        switch kind {
        case "absent":
            data = nil
            expected = nil
        case "binary":
            data = Data([255, 254])
            expected = .data(Data([255, 254]))
        case "text":
            data = Data("NFT café".utf8)
            expected = .string("NFT café")
        case "invalidJSON":
            data = Data("{}".utf8)
            expected = .string("{}")
        case "jsonWithoutThumbnail":
            data = Data(#"{"attributes":[]}"#.utf8)
            expected = .dictionary(["attributes": .dictionary([:])])
        default:
            data = Data(#"{"thumb":"https://example.com/thumb.png","attributes":[{"trait_type":"Color","value":"red"},{"trait_type":"Color","value":"blue"}]}"#.utf8)
            expected = .dictionary([
                "thumbnail": .url(try #require(URL(string: "https://example.com/thumb.png"))),
                "attributes": .dictionary(["Color": .string("blue")])
            ])
        }
        let http = DABMockResponses.client(queries: [
            "metadata": try DABMockResponses.candid(EXT.Result_4.ok(.nonfungible(metadata: data)))
        ])
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        #expect(try await actor.nftDetails(.number(42)).metadata == expected)
    }

    @Test(arguments: [false, true])
    func allNftsPreservesOrderAndMetadata(empty: Bool) async throws {
        let tokens: [CandidTuple2<UInt32, EXT.Metadata>] = empty ? [] : [
            .init(9, .nonfungible(metadata: Data("nine".utf8))),
            .init(2, .nonfungible(metadata: Data("two".utf8)))
        ]
        let http = DABMockResponses.client(queries: ["getTokens": try DABMockResponses.candid(tokens)])
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        let nfts = try await actor.allNfts()
        #expect(nfts.map(\.index) == (empty ? [] : [.number(9), .number(2)]))
        #expect(nfts.map(\.metadata) == (empty ? [] : [.string("nine"), .string("two")]))
        #expect(nfts.allSatisfy { $0.standard == .ext && $0.canister == canister })
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        try assertQuery(request, method: "getTokens")
        #expect(try CandidDeserialiser().decode(#require(DABMockResponses.envelope(request).content.arg)).isEmpty)
    }

    @Test(arguments: [false, true])
    func userTokensUsesAccountAddressAndMapsResults(empty: Bool) async throws {
        let tokens: [CandidTuple3<UInt32, EXT.Listing?, Data?>] = empty ? [] : [
            .init(9, nil, Data("nine".utf8)), .init(2, nil, Data("two".utf8))
        ]
        let http = DABMockResponses.client(queries: ["tokens_ext": try DABMockResponses.candid(EXT.Result_1.ok(tokens))])
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        let nfts = try await actor.userTokens(user)
        #expect(nfts.map(\.index) == (empty ? [] : [.number(9), .number(2)]))
        #expect(nfts.map(\.metadata) == (empty ? [] : [.string("nine"), .string("two")]))
        #expect(nfts.allSatisfy { $0.standard == .ext && $0.canister == canister })
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        try assertQuery(request, method: "tokens_ext")
        #expect(try DABMockResponses.arguments(String.self, from: request) ==
                "1c7a48ba6a562aa9eaa2481a9049cdf0433b9738c992d698c31d8abf89cadc79")
    }

    @Test(arguments: [false, true])
    func rejectsFungibleMetadata(all: Bool) async throws {
        let metadata = EXT.Metadata.fungible(decimals: 8, metadata: nil, name: "Token", symbol: "TKN")
        let reply = try all
            ? DABMockResponses.candid([CandidTuple2<UInt32, EXT.Metadata>(42, metadata)])
            : DABMockResponses.candid(EXT.Result_4.ok(metadata))
        let http = DABMockResponses.client(queries: [all ? "getTokens" : "metadata": reply])
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftActorError.invalidMetaData) {
            if all { _ = try await actor.allNfts() }
            else { _ = try await actor.nftDetails(.number(42)) }
        }
    }

    @Test(arguments: [false, true], [false, true])
    func propagatesCanisterErrors(userOnly: Bool, invalidToken: Bool) async throws {
        let error: EXT.CommonError = invalidToken ? .InvalidToken("missing") : .Other("unavailable")
        let reply = try userOnly
            ? DABMockResponses.candid(EXT.Result_1.err(error))
            : DABMockResponses.candid(EXT.Result_4.err(error))
        let http = DABMockResponses.client(queries: [userOnly ? "tokens_ext" : "metadata": reply])
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            if userOnly { _ = try await actor.userTokens(user) }
            else { _ = try await actor.nftDetails(.number(42)) }
        } throws: { error in
            switch error {
            case EXT.CommonError.InvalidToken(let token): return invalidToken && token == "missing"
            case EXT.CommonError.Other(let message): return !invalidToken && message == "unavailable"
            default: return false
            }
        }
    }

    @Test func rejectsOverflowingIndexWithoutRequest() async throws {
        let http = DABMockResponses.client()
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftActorError.invalidIndex) {
            try await actor.nftDetails(.number(BigUInt(UInt32.max) + 1))
        }
        #expect(http.requests.isEmpty)
    }

    @Test func rejectsStringIndexWithoutRequest() async throws {
        let http = DABMockResponses.client()
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICPNftDetails.Index.IndexError.notANumber) {
            try await actor.nftDetails(.string("42"))
        }
        #expect(http.requests.isEmpty)
    }

    @Test(arguments: ["details", "all", "user"])
    func propagatesHTTPFailure(operation: String) async throws {
        let http = MockHttpClient(response: HttpResponse(data: Data("unavailable".utf8), statusCode: 503))
        let actor = EXTNftActor(canister, DABMockResponses.requestClient(http))
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
        #expect(request.url.path.hasSuffix("/rrkah-fqaaa-aaaaa-aaaaq-cai/query"), sourceLocation: sourceLocation)
    }
}
