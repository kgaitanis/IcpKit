import Foundation
import Candid
import IcpKit
import PotentCBOR
import Testing
import TestSupport

/// Wire fixtures run the real generated services and request client, including update polling.
enum DABMockResponses {
    static func candid<T: Encodable>(_ value: T) throws -> Data {
        try CandidSerialiser().encode([CandidEncoder().encode(value)])
    }

    static func client(queries: [String: Data] = [:], update: Data? = nil) -> MockHttpClient {
        MockHttpClient { request in
            let content = try envelope(request).content
            switch content.request_type {
            case "query":
                let method = try #require(content.method_name)
                let reply = try #require(queries[method], "Unexpected query: \(method)")
                return HttpResponse(data: try CBORSerialization.data(from: .map([
                    "status": "replied", "reply": .map(["arg": .byteString(reply)])
                ])), statusCode: 200)
            case "call":
                _ = try #require(update, "Unexpected update")
                return HttpResponse(statusCode: 202)
            case "read_state":
                let reply = try #require(update)
                let path = try #require(content.paths?.first { $0.count == 3 })
                let requestId = path[1]
                let status: CBOR = .array([2, .byteString(Data("status".utf8)), .array([3, .byteString(Data("replied".utf8))])])
                let result: CBOR = .array([2, .byteString(Data("reply".utf8)), .array([3, .byteString(reply)])])
                let tree: CBOR = .array([2, .byteString(Data("request_status".utf8)),
                    .array([2, .byteString(requestId), .array([1, status, result])])])
                let certificate = try CBORSerialization.data(from: .map([
                    "tree": tree, "signature": .byteString(Data())
                ]))
                return HttpResponse(data: try CBORSerialization.data(from: .map([
                    "certificate": .byteString(certificate)
                ])), statusCode: 200)
            default:
                Issue.record("Unexpected request type: \(content.request_type)")
                throw FixtureError.unexpectedRequest
            }
        }
    }

    static func requestClient(_ http: MockHttpClient) -> ICPRequestClient {
        // Fabricated certificates have no signature; only these offline fixtures disable verification.
        ICPRequestClient(network: ICPNetwork.mainnet.withRootKey(nil), client: http)
    }

    static func envelope(_ request: HttpRequest) throws -> Envelope {
        try ICPCryptography.CBOR.deserialise(Envelope.self, from: #require(request.body))
    }

    static func arguments<T: Decodable>(_ type: T.Type, from request: HttpRequest) throws -> T {
        let data = try #require(envelope(request).content.arg)
        let values = try CandidDeserialiser().decode(data)
        #expect(values.count == 1)
        return try CandidDecoder().decode(type, from: #require(values.first))
    }

    struct Envelope: Decodable {
        let content: Content
        let sender_sig: Data?
    }

    struct Content: Decodable {
        let request_type: String
        let method_name: String?
        let canister_id: Data?
        let sender: Data
        let arg: Data?
        let paths: [[Data]]?
    }

    private enum FixtureError: Error { case unexpectedRequest }
}

/// Uses the existing public fixture key; signatures are never sent to a real network.
struct DABTestSigner: ICPSigningPrincipal {
    var rawPublicKey: Data { PublicKeys.devWallet1 }
    var principal: ICPPrincipal { devWallet1.principal }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        Data(repeating: 0, count: 64)
    }
}
