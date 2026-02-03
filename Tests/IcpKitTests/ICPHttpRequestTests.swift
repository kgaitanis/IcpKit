//
//  ICPHttpRequestTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import XCTest
import PotentCBOR
@testable import IcpKit

final class ICPHttpRequestTests: XCTestCase {

    func testReadStateHttpRequest() async throws {
        let readStateRequest = try await ICPRequest(
            .readState(paths: []),
            canister: ICPSystemCanisters.ledger
        )
        let httpRequest = readStateRequest.httpRequest
        XCTAssertEqual(httpRequest.method, "POST")
        XCTAssertEqual(httpRequest.url.absoluteString, "https://icp-api.io/api/v2/canister/\(ICPSystemCanisters.ledger.string)/read_state")
        XCTAssertTrue(httpRequest.headers.contains(where: { $0.key == "Content-Type" && $0.value == "application/cbor" }))
        
        let cborBody = httpRequest.body!
        XCTAssertEqual(cborBody.prefix(3), Data([0xD9, 0xD9, 0xF7]))
        let cborBodyWithoutTag = Data(cborBody.suffix(from: 3)) // ignore the self describing tag
        let decodedBody = try CBORDecoder.default.decode(ReadRequestDecodable.self, from: cborBodyWithoutTag)
        
        XCTAssertEqual(decodedBody.content.request_type, "read_state")
        //XCTAssertEqual(decodedBody.content.sender, principal1.bytes)
        XCTAssertEqual(decodedBody.content.nonce.count, 32)
        XCTAssertNil(decodedBody.sender_delegation)
        let expiry = Date(timeIntervalSince1970: TimeInterval(decodedBody.content.ingress_expiry / 1_000_000_000))
        XCTAssertLessThanOrEqual(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds-1), expiry)
        XCTAssertGreaterThan(Date.now.advanced(by: ICPRequestBuilder.defaultIngressExpirySeconds+1), expiry)
    }

    func testRequestIncludesDelegation() async throws {
        let delegation = ICPDelegation(
            pubkey: Data([0xAA, 0xBB]),
            expiration: 1_700_000_000_000_000_000,
            targets: [ICPSystemCanisters.ledger]
        )
        let signedDelegation = ICPSignedDelegation(
            delegation: delegation,
            signature: Data([0xCC, 0xDD])
        )

        let mock = MockSigningPrincipal(
            principal: ICPPrincipal(Data([0x01])),
            publicKeyDer: Data([0x30, 0x01, 0x02]),
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
        XCTAssertEqual(cborBody.prefix(3), Data([0xD9, 0xD9, 0xF7]))
        let cborBodyWithoutTag = Data(cborBody.suffix(from: 3))
        let decodedBody = try CBORDecoder.default.decode(ReadRequestDecodable.self, from: cborBodyWithoutTag)

        XCTAssertEqual(decodedBody.sender_pubkey, mock.publicKeyDer)
        XCTAssertEqual(decodedBody.sender_sig, mock.signature)
        XCTAssertEqual(decodedBody.sender_delegation, mock.delegationChain)
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

private struct MockSigningPrincipal: ICPSigningPrincipal, ICPDelegationProvider, ICPDerPublicKeyProvider {
    let principal: ICPPrincipal
    let rawPublicKey: Data
    let publicKeyDer: Data
    let signature: Data
    let delegationChain: [ICPSignedDelegation]

    init(principal: ICPPrincipal, publicKeyDer: Data, signature: Data, delegationChain: [ICPSignedDelegation]) {
        self.principal = principal
        self.rawPublicKey = Data([0x04])
        self.publicKeyDer = publicKeyDer
        self.signature = signature
        self.delegationChain = delegationChain
    }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        signature
    }
}
