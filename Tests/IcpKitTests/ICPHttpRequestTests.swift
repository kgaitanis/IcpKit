//
//  ICPHttpRequestTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation
import Testing
import PotentCBOR
import Candid
@testable import IcpKit

struct ICPHttpRequestTests {

    @Test func readStateHttpRequest() async throws {
        let readStateRequest = try await ICPRequest(
            .readState(paths: []),
            canister: ICPSystemCanisters.ledger
        )
        let httpRequest = readStateRequest.httpRequest
        #expect(httpRequest.method == "POST")
        #expect(httpRequest.url.absoluteString == "https://icp-api.io/api/v2/canister/\(ICPSystemCanisters.ledger.string)/read_state")
        #expect(httpRequest.headers.contains(where: { $0.key == "Content-Type" && $0.value == "application/cbor" }))
        
        let cborBody = httpRequest.body!
        #expect(cborBody.prefix(3) == Data([0xD9, 0xD9, 0xF7]))
        let cborBodyWithoutTag = Data(cborBody.suffix(from: 3)) // ignore the self describing tag
        let decodedBody = try CBORDecoder.default.decode(ReadRequestDecodable.self, from: cborBodyWithoutTag)
        
        #expect(decodedBody.content.request_type == "read_state")
        //#expect(decodedBody.content.sender == principal1.bytes)
        #expect(decodedBody.content.nonce.count == 32)
        #expect(decodedBody.sender_delegation == nil)
        let expiry = Date(timeIntervalSince1970: TimeInterval(decodedBody.content.ingress_expiry / 1_000_000_000))
        #expect(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds-1) <= expiry)
        #expect(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds+1) > expiry)

        for nanos: UInt64 in [0, 1_000_000_000, 1_500_000_000] {
            #expect(Date(nanoSecondsSince1970: nanos).nanoSecondsSince1970 == nanos)
        }
        let nonHTTP = HttpRequest(method: "GET", url: try #require(URL(string: "data:text/plain,hello")),
                                  body: nil, headers: [:], timeout: 1)
        await #expect(throws: URLError(.badServerResponse)) {
            _ = try await UrlSessionHttpClient().fetch(nonHTTP)
        }

        let canister = ICPSystemCanisters.ledger
        let method = ICPMethod(canister: canister, methodName: "test", arg: .bool(true))
        #expect(method.args == [.bool(true)])
        let localURL: URL = "http://127.0.0.1:4943"
        let network = ICPNetwork.local(baseURL: localURL)
        #expect(ICPRequestClient(network: network).network.baseURL == network.baseURL)
        let reply = CandidSerialiser().encode([.text("answer")])
        let queryBody = try CBORSerialization.data(from: .map([
            "status": "replied", "reply": .map(["arg": .byteString(reply)])
        ]))
        let queryClient = ICPRequestClient(RequestResponseClient(response: HttpResponse(data: queryBody, statusCode: 200)))
        #expect(try await queryClient.query(.uncertified, method, effectiveCanister: canister) == [.text("answer")])

        for status in [200, 202] {
            let client = ICPRequestClient(RequestResponseClient(response: HttpResponse(statusCode: status)))
            #expect(try await client.call(method, effectiveCanister: canister).count == 32)
            await #expect {
                try await client.query(method, effectiveCanister: canister)
            } throws: { error in
                guard case ICPRemoteClientError.noResponseData = error else { return false }
                return true
            }
            await #expect {
                try await client.readState(paths: [], effectiveCanister: canister)
            } throws: { error in
                guard case ICPRemoteClientError.noResponseData = error else { return false }
                return true
            }
        }
        for body in [Data("unavailable".utf8), nil] {
            let client = ICPRequestClient(RequestResponseClient(response: HttpResponse(data: body, statusCode: 503)))
            await #expect {
                try await client.query(method, effectiveCanister: canister)
            } throws: { error in
                guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
                return code == 503 && message == (body == nil ? "" : "unavailable")
            }
        }
        for payload: CBOR in [
            .map(["status": "rejected", "reject_code": 4, "reject_message": "denied", "error_code": "IC0406"]),
            .map(["status": "replied"])
        ] {
            let body = try CBORSerialization.data(from: payload)
            let client = ICPRequestClient(RequestResponseClient(response: HttpResponse(data: body, statusCode: 200)))
            await #expect {
                try await client.query(method, effectiveCanister: canister)
            } throws: { error in
                if case ICPRemoteClientError.requestRejected(let code, let message, let errorCode) = error {
                    return code == .canisterReject && message == "denied" && errorCode == "IC0406"
                }
                if case ICPRemoteClientError.malformedResponse = error {
                    return payload["status"] == "replied"
                }
                return false
            }
        }
        let malformedClient = ICPRequestClient(RequestResponseClient(response: HttpResponse(data: Data([0xff]), statusCode: 200)))
        await #expect(throws: (any Error).self) {
            try await malformedClient.query(method, effectiveCanister: canister)
        }
        let requestID = Data(repeating: 7, count: 32)
        let polling = RequestPollingClient(statuses: [nil, "received", "processing", "replied"], reply: reply)
        let pollingClient = ICPRequestClient(network: network, client: polling)
        #expect(try await pollingClient.pollRequestStatus(
            requestId: requestID, effectiveCanister: canister, for: .seconds(5), repeatEvery: .zero
        ) == [.text("answer")])
        #expect(polling.readCount == 4)
        for status in ["done", "unknown", "replied", "rejected", "processing", "received"] {
            let client = ICPRequestClient(network: network, client: RequestPollingClient(statuses: [status]))
            await #expect {
                try await client.pollRequestStatus(
                    requestId: requestID, effectiveCanister: canister, for: .zero, repeatEvery: .zero
                )
            } throws: { error in
                switch (status, error) {
                case ("done", ICPPollingError.requestIsDone): return true
                case ("unknown", ICPPollingError.parsingError),
                     ("replied", ICPPollingError.parsingError),
                     ("rejected", ICPPollingError.parsingError): return true
                case ("processing", ICPPollingError.timeout),
                     ("received", ICPPollingError.timeout): return true
                default: return false
                }
            }
        }
        for code: UInt8 in [0, 4] {
            let client = ICPRequestClient(network: network, client: RequestPollingClient(
                statuses: ["rejected"], rejectCode: code, rejectMessage: "denied"
            ))
            await #expect {
                try await client.pollRequestStatus(requestId: requestID, effectiveCanister: canister)
            } throws: { error in
                switch error {
                case ICPPollingError.parsingError: return code == 0
                case ICPPollingError.requestRejected(let rejection, let message):
                    return code == 4 && rejection == .canisterReject && message == "denied"
                default: return false
                }
            }
        }
        let callClient = ICPRequestClient(network: network, client: RequestPollingClient(statuses: ["replied"], reply: reply))
        #expect(try await callClient.callAndPoll(method, effectiveCanister: canister, repeatEvery: .zero) == [.text("answer")])
        #expect(try await callClient.query(.certified, method, effectiveCanister: canister) == [.text("answer")])
        let missing = ICPReadStateResponse(stateValues: [:])
        #expect(missing.stringValueForPath(endingWith: "missing") == nil)
    }

    @Test func requestIncludesDelegation() async throws {
        let delegation = ICPDelegation(
            pubkey: Data([0xAA, 0xBB]),
            expiration: 4_000_000_000_000_000_000,
            targets: [ICPSystemCanisters.ledger]
        )
        let signedDelegation = ICPSignedDelegation(
            delegation: delegation,
            signature: Data([0xCC, 0xDD])
        )

        let mock = MockSigningPrincipal(
            principal: ICPPrincipal(Data([0x01])),
            publicKey: try DelegationTestSigner().publicKey,
            signature: Data([0x99, 0x88]),
            delegationChain: [signedDelegation]
        )

        let readStateRequest = try await ICPRequest(
            .readState(paths: []),
            canister: ICPSystemCanisters.ledger,
            sender: mock
        )
        let httpRequest = readStateRequest.httpRequest

        let cborBody = httpRequest.body!
        #expect(cborBody.prefix(3) == Data([0xD9, 0xD9, 0xF7]))
        let cborBodyWithoutTag = Data(cborBody.suffix(from: 3))
        let decodedBody = try CBORDecoder.default.decode(ReadRequestDecodable.self, from: cborBodyWithoutTag)

        #expect(decodedBody.sender_pubkey == (try mock.publicKey.derRepresentation))
        #expect(decodedBody.sender_sig == mock.signature)
        #expect(decodedBody.sender_delegation == mock.delegationChain)
    }
}

private struct ReadRequestDecodable: Decodable {
    let content: Content
    let sender_pubkey: Data?
    let sender_sig: Data?
    let sender_delegation: [ICPSignedDelegation]?
    
    struct Content: Decodable {
        let request_type: String
        let sender: Data
        let nonce: Data
        let ingress_expiry: Int
        let paths: [[Data]]
    }
}

private struct MockSigningPrincipal: ICPSigningPrincipal {
    let principal: ICPPrincipal
    let publicKey: ICPPublicKey
    let signature: Data
    let delegationChain: [ICPSignedDelegation]
    var rawPublicKey: Data { publicKey.rawRepresentation }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        signature
    }
}

private final class RequestResponseClient: HttpClient {
    let data: Data?
    let statusCode: Int

    init(response: HttpResponse) {
        data = response.data
        statusCode = response.statusCode
    }

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        HttpResponse(data: data, statusCode: statusCode)
    }
}

/// Builds an unsigned local-replica certificate for the actual requested ID.
private final class RequestPollingClient: @unchecked Sendable, HttpClient {
    let statuses: [String?]
    let reply: Data?
    let rejectCode: UInt8?
    let rejectMessage: String?
    private let lock = NSLock()
    private var count = 0
    var readCount: Int { lock.withLock { count } }

    init(statuses: [String?], reply: Data? = nil, rejectCode: UInt8? = nil, rejectMessage: String? = nil) {
        self.statuses = statuses
        self.reply = reply
        self.rejectCode = rejectCode
        self.rejectMessage = rejectMessage
    }

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        if request.url.lastPathComponent == "call" {
            return HttpResponse(statusCode: 202)
        }
        let envelope = try ICPCryptography.CBOR.deserialiseCbor(from: #require(request.body))
        let paths = try #require(envelope["content"]?["paths"]?.arrayValue)
        let requestID = try #require(paths.compactMap { $0.arrayValue }.first { $0.count > 1 }?[1].bytesStringValue)
        let status = lock.withLock {
            defer { count += 1 }
            return statuses[min(count, statuses.count - 1)]
        }
        var fields: [(String, Data)] = []
        if let status { fields.append(("status", Data(status.utf8))) }
        if let reply { fields.append(("reply", reply)) }
        if let rejectCode { fields.append(("reject_code", Data([rejectCode]))) }
        if let rejectMessage { fields.append(("reject_message", Data(rejectMessage.utf8))) }
        let leaves: [CBOR] = fields.map { name, value in
            .array([2, .byteString(Data(name.utf8)), .array([3, .byteString(value)])])
        }
        let subtree = leaves.reduce(CBOR.array([0])) { .array([1, $0, $1]) }
        let tree: CBOR = .array([2, .byteString(Data("request_status".utf8)),
            .array([2, .byteString(requestID), subtree])])
        let certificate = try CBORSerialization.data(from: .map([
            "tree": tree, "signature": .byteString(Data())
        ]))
        let response = try CBORSerialization.data(from: .map(["certificate": .byteString(certificate)]))
        return HttpResponse(data: response, statusCode: 200)
    }
}
