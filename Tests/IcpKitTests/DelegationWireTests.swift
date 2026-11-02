import Foundation
import Testing
import PotentCBOR
@testable import IcpKit

struct DelegationWireTests {
    @Test func anonymousEnvelopeOmitsAuthentication() throws {
        let content = try ICPRequestBuilder.buildContent(.readState(paths: []), sender: nil)
        let data = try JSONEncoder().encode(ICPRequestEnvelope(content: content))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["sender_pubkey"] == nil)
        #expect(object["sender_sig"] == nil)
        #expect(object["sender_delegation"] == nil)
    }

    @Test func targetsAreByteBlobs() throws {
        let delegation = ICPDelegation(pubkey: Data([1]), expiration: 123, targets: [ICPPrincipal(Data([4]))])
        struct Wire: Decodable { let targets: [Data] }
        let encoded = try CBOREncoder.default.encode(delegation)
        let wire = try CBORDecoder.default.decode(Wire.self, from: encoded)
        #expect(wire.targets == [Data([4])])
    }

    @Test func permissionsAreNotSilentlyDiscarded() throws {
        let data = Data(#"{"pubkey":"AQ==","expiration":123,"permissions":"queries"}"#.utf8)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ICPDelegation.self, from: data)
        }
    }

    // Independent fixtures: Python hashlib + unsigned LEB128 and hand-encoded CBOR,
    // with OpenSSL 3.6.3 Ed25519 signatures (seeds 01*32 and 02*32).
    @Test func independentDelegationAndEnvelopeVector() async throws {
        let root = try hex("302a300506032b65700321008a88e3dd7409f195fd52db2d3cba5d72ca6709bf1d94121bf3748801b40f6f5c")
        let leaf = try hex("302a300506032b65700321008139770ea87d175f56a35466c34c7ecccb8d8a91b4ee37a25df60f5b8fc9b394")
        let signature = try hex("05cbc427c605cbb5a50454021e03baddb2836686c8df6b1773987845ac576fe9e9b13a97a4da744f33b72a8f104bd2c5a54ba81d26905afae1339d5e7c069c02")
        let delegation = ICPDelegation(pubkey: leaf, expiration: 4_000_000_000_000_000_000, targets: [ICPPrincipal(Data([4]))])
        #expect(try delegation.requestId() == hex("005a97783a5b31db4667aff7bf54b19bfac94177b54b9e29aad3f72a0a48705f"))
        let signed = ICPSignedDelegation(delegation: delegation, signature: signature)
        let signer = try DelegationTestSigner(algorithm: .ed25519, seed: 2)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: root, to: signer, chain: [signed])
        let content = ReadStateRequestContent(request_type: .readState, sender: identity.principal.bytes, nonce: Data(), ingress_expiry: 4_000_000_000_000_000_000, paths: [])
        let envelope = ICPRequestEnvelope(content: content, sender_pubkey: root, sender_sig: Data(repeating: 0, count: 64), sender_delegation: [signed])
        let fixture = try hex("a467636f6e74656e74a56c726571756573745f747970656a726561645f73746174656673656e646572581d5c6c7ea968370729f5176d76f4659565f939c69b80b5a6ba03556c1a02656e6f6e6365406e696e67726573735f6578706972791b3782dace9d900000657061746873806d73656e6465725f7075626b6579582c302a300506032b65700321008a88e3dd7409f195fd52db2d3cba5d72ca6709bf1d94121bf3748801b40f6f5c6a73656e6465725f7369675840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007173656e6465725f64656c65676174696f6e81a26a64656c65676174696f6ea3667075626b6579582c302a300506032b65700321008139770ea87d175f56a35466c34c7ecccb8d8a91b4ee37a25df60f5b8fc9b3946a65787069726174696f6e1b3782dace9d9000006774617267657473814104697369676e6174757265584005cbc427c605cbb5a50454021e03baddb2836686c8df6b1773987845ac576fe9e9b13a97a4da744f33b72a8f104bd2c5a54ba81d26905afae1339d5e7c069c02")
        #expect(try CBORSerialization.cbor(from: CBOREncoder.default.encode(envelope)) == CBORSerialization.cbor(from: fixture))
        let decoded = try CBORDecoder.default.decode(ICPDelegation.self, from: CBOREncoder.default.encode(delegation))
        #expect(decoded == delegation)
    }

    @Test func emptyChainsAreOmittedFromCBOR() throws {
        let content = try ICPRequestBuilder.buildContent(.readState(paths: []), sender: nil)
        let anonymous = ICPRequestEnvelope(content: content)
        #expect(anonymous.sender_delegation.isEmpty)
        let tree = try CBORSerialization.cbor(from: CBOREncoder.default.encode(anonymous))
        guard case .map(let fields) = tree else { Issue.record("Expected map"); return }
        #expect(fields.count == 1)
        let signed = ICPRequestEnvelope(content: content, sender_pubkey: Data([1]), sender_sig: Data([2]))
        let signedTree = try CBORSerialization.cbor(from: CBOREncoder.default.encode(signed))
        guard case .map(let signedFields) = signedTree else { Issue.record("Expected map"); return }
        #expect(signedFields.count == 3)
        #expect(signedFields[.utf8String("sender_delegation")] == nil)
    }

    @Test func nilAndEmptyTargetsStayDistinct() throws {
        let unrestricted = ICPDelegation(pubkey: Data([1]), expiration: 123)
        let denied = ICPDelegation(pubkey: Data([1]), expiration: 123, targets: [])
        #expect(try unrestricted.requestId() != denied.requestId())
        let first = try CBORDecoder.default.decode(ICPDelegation.self, from: CBOREncoder.default.encode(unrestricted))
        let second = try CBORDecoder.default.decode(ICPDelegation.self, from: CBOREncoder.default.encode(denied))
        #expect(first.targets == nil)
        #expect(second.targets == [])
    }

    // OpenSSL dgst -sha256 -sign over "icp delegation verification", using
    // scalar 01*32. Signatures converted from DER INTEGERs to 32-byte r || s.
    @Test func independentECDSAVectors() throws {
        let vectors = [
            ("3059301306072a8648ce3d020106082a8648ce3d030107034200046ff03b949241ce1dadd43519e6960e0a85b41a69a05c328103aa2bce1594ca163c4f753a55bf01dc53f6c0b0c7eee78b40c6ff7d25a96e2282b989cef71c144a",
             "df850235e9992ffc02a6a267a573f1f8aea4bd461a0cda619b23a3bcc890ae737dc08b7168b69c4734785b49935297d2a78bdb5d6cee5278f14e2dbb7e1610ee"),
            ("3056301006072a8648ce3d020106052b8104000a034200041b84c5567b126440995d3ed5aaba0565d71e1834604819ff9c17f5e9d5dd078f70beaf8f588b541507fed6a642c5ab42dfdf8120a7f639de5122d47a69a8e8d1",
             "ed11fc29f1b635add0037fdf9e279cb928052553dc4068d380e52f0cae14c365afe56a0378d479e8ed3787e9769cb832bed98edaeaab70e174e94fe7291228ed")
        ]
        for (der, signature) in vectors {
            let key = try ICPPublicKey(derRepresentation: hex(der))
            try ICPCryptography.verify(signature: hex(signature), message: Data("icp delegation verification".utf8), publicKey: key)
            #expect(throws: ICPPublicKey.Error.invalidSignature) {
                try ICPCryptography.verify(signature: hex(signature), message: Data("wrong".utf8), publicKey: key)
            }
        }
    }

    private func hex(_ string: String) throws -> Data {
        try #require(Data.fromHex(string))
    }
}
