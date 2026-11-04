//
//  ICPRequestClientRootKeyTests.swift
//  UnitTests
//

import Foundation
import Testing
import TestSupport

@testable import IcpKit

struct ICPRequestClientRootKeyTests {
    @Test func missingRootKeyStaysNil() throws {
        let url = try #require(URL(string: "http://127.0.0.1:4943"))
        #expect(ICPNetwork(baseURL: url).rootKey == nil)
        #expect(ICPNetwork.local(baseURL: url).rootKey == nil)
        #expect(ICPNetwork.mainnet.withRootKey(nil).rootKey == nil)
    }


    @Test func rootKeyControlsSignatureVerification() async throws {
        let url = try #require(URL(string: "http://127.0.0.1:4943"))
        let certificate = try ICPCryptography.CBOR.serialise(
            CertificateTest(tree: [0], signature: Data(repeating: 0, count: 48))
        )
        let body = try ICPCryptography.CBOR.serialise(ReadStateTest(certificate: certificate))
        let client = ICPRequestClient(
            network: ICPNetwork(baseURL: url),
            client: MockHttpClient(response: HttpResponse(data: body, statusCode: 200))
        )
        let canister = ICPPrincipal("aaaaa-aa")
        _ = try await client.readState(paths: [], effectiveCanister: canister)
        let key = try #require(ICPNetwork.mainnet.rootKey)
        let verifyingClient = client.withRootKey(key)
        await #expect(throws: ICPStateCertificateError.self) {
            _ = try await verifyingClient.readState(paths: [], effectiveCanister: canister)
        }
        let clearedClient = ICPRequestClient(
            network: verifyingClient.network.withRootKey(nil),
            client: MockHttpClient(response: HttpResponse(data: body, statusCode: 200))
        )
        _ = try await clearedClient.readState(paths: [], effectiveCanister: canister)
    }

    @Test func rejectsMalformedRootKeyDER() async throws {
        let key = try #require(ICPNetwork.mainnet.rootKey)
        let prefix = try #require(Data.fromHex("308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100"))
        let valid = prefix + key
        var wrongAlgorithm = valid
        wrongAlgorithm[19] ^= 1
        var wrongCurve = valid
        wrongCurve[33] ^= 1
        var unusedBits = valid
        unusedBits[36] = 1
        var wrongTag = valid
        wrongTag[0] = 0x31
        var wrongLength = valid
        wrongLength[2] -= 1
        for malformed in [Data(), key, Data(valid.dropLast()), valid + Data([0]),
                          wrongAlgorithm, wrongCurve, unusedBits, wrongTag, wrongLength] {
            let body = try ICPCryptography.CBOR.serialise(StatusResponseTest(root_key: malformed))
            let client = ICPRequestClient(
                network: .mainnet,
                client: MockHttpClient(response: HttpResponse(data: body, statusCode: 200))
            )
            await #expect {
                _ = try await client.fetchRootKey()
            } throws: { error in
                guard case ICPRemoteClientError.invalidRootKey = error else { return false }
                return true
            }
        }
    }

    @Test func fetchedRootKeyCanBeInstalled() async throws {
        let expectedRootKey = try #require(ICPNetwork.mainnet.rootKey)
        let derPrefix = try #require(Data.fromHex("308182301d060d2b0601040182dc7c0503010201060c2b0601040182dc7c05030201036100"))
        let cbor = try ICPCryptography.CBOR.serialise(StatusResponseTest(root_key: derPrefix + expectedRootKey))
        let mockClient = MockHttpClient(
            response: HttpResponse(data: cbor, statusCode: 200)
        )

        let network = ICPNetwork.local(
            baseURL: try #require(URL(string: "http://127.0.0.1:4943"))
        )
        let client = ICPRequestClient(network: network, client: mockClient)

        let rootKey = try await client.fetchRootKey()
        let verifiedClient = client.withRootKey(rootKey)

        #expect(verifiedClient.network.rootKey == expectedRootKey)
        #expect(mockClient.lastRequest?.url == network.statusURL)
        #expect(mockClient.lastRequest?.method == "GET")
        #expect(mockClient.lastRequest?.body == nil)
        #expect(mockClient.lastRequest?.timeout == 30)

        for response in [
            HttpResponse(data: Data("unavailable".utf8), statusCode: 503),
            HttpResponse(statusCode: 503),
            HttpResponse(statusCode: 200),
            HttpResponse(data: try ICPCryptography.CBOR.serialise(StatusResponseTest(root_key: nil)), statusCode: 200)
        ] {
            let failingClient = ICPRequestClient(MockHttpClient(response: response))
            await #expect {
                try await failingClient.fetchRootKey()
            } throws: { error in
                switch error {
                case ICPRemoteClientError.failed(let code, let message):
                    return response.statusCode == 503 && code == 503 && message == (response.data == nil ? "" : "unavailable")
                case ICPRemoteClientError.noResponseData:
                    return response.data == nil
                case ICPRemoteClientError.missingRootKey:
                    return response.statusCode == 200 && response.data != nil
                default: return false
                }
            }
        }
    }
}

private struct CertificateTest: Encodable {
    let tree: [Int]
    let signature: Data
}

private struct ReadStateTest: Encodable {
    let certificate: Data
}

private struct StatusResponseTest: Encodable {
    let root_key: Data?
}
