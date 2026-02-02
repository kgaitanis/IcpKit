//
//  ICPRequestClientRootKeyTests.swift
//  UnitTests
//

import XCTest

@testable import IcpKit

final class ICPRequestClientRootKeyTests: XCTestCase {

    func testFetchRootKeySetsNetworkRootKey() async throws {
        let expectedRootKey = Data([0x01, 0x02, 0x03, 0x04])
        let cbor = try ICPCryptography.CBOR.serialise(StatusResponseTest(root_key: expectedRootKey))
        let mockClient = MockHttpClient(
            response: HttpResponse(data: cbor, statusCode: 200)
        )

        let network = ICPNetwork.local(
            baseURL: URL(string: "http://127.0.0.1:4943")!,
            verifyCertificates: true
        )
        let client = ICPRequestClient(network: network, client: mockClient)

        let rootKey = try await client.fetchRootKey()
        let verifiedClient = client.withRootKey(rootKey)

        XCTAssertEqual(verifiedClient.network.rootKey, expectedRootKey)
        XCTAssertEqual(mockClient.lastRequest?.url, network.statusURL)
    }
}

private struct StatusResponseTest: Encodable {
    let root_key: Data?
}

private final class MockHttpClient: @unchecked Sendable, HttpClient {
    private(set) var lastRequest: HttpRequest?
    private let response: HttpResponse

    init(response: HttpResponse) {
        self.response = response
    }

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        lastRequest = request
        return response
    }
}
