//
//  ICPDelegatedIdentityTests.swift
//

import XCTest
import CryptoKit
import Security
import secp256k1
@testable import IcpKit
@preconcurrency import PotentASN1

final class ICPDelegatedIdentityTests: XCTestCase {
    func testInitValidP256Chain() throws {
        let fromKey = P256.Signing.PrivateKey()
        let toKey = P256.Signing.PrivateKey()

        let fromDer = try TestKeyDer.p256PublicKeyDer(fromKey.publicKey)
        let toDer = try TestKeyDer.p256PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestKeyDer.signDelegation(delegation, with: fromKey)

        let toIdentity = try P256SigningPrincipal(privateKey: toKey)
        let delegated = try ICPDelegatedIdentity(
            fromPublicKeyDer: fromDer,
            to: toIdentity,
            chain: [signed]
        )

        XCTAssertEqual(delegated.publicKeyDer, fromDer)
        XCTAssertEqual(delegated.rawPublicKey, fromDer)
        XCTAssertEqual(delegated.principal, ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: fromDer))
        XCTAssertEqual(delegated.delegationChain, [signed])
    }

    func testInitValidEd25519Chain() throws {
        let fromKey = Curve25519.Signing.PrivateKey()
        let toKey = Curve25519.Signing.PrivateKey()

        let fromDer = try TestKeyDer.ed25519PublicKeyDer(fromKey.publicKey)
        let toDer = try TestKeyDer.ed25519PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestKeyDer.signDelegation(delegation, with: fromKey)

        let toIdentity = try Ed25519SigningPrincipal(privateKey: toKey)
        let delegated = try ICPDelegatedIdentity(
            fromPublicKeyDer: fromDer,
            to: toIdentity,
            chain: [signed]
        )

        XCTAssertEqual(delegated.publicKeyDer, fromDer)
        XCTAssertEqual(delegated.delegationChain, [signed])
    }

    func testInitValidSecp256k1Chain() throws {
        let fromKey = try TestSecp256k1.generatePrivateKey()
        let toKey = try TestSecp256k1.generatePrivateKey()

        let fromDer = try ICPCryptography.der(uncompressedEcPublicKey: fromKey.publicKeyUncompressed)
        let toDer = try ICPCryptography.der(uncompressedEcPublicKey: toKey.publicKeyUncompressed)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestSecp256k1.signDelegation(delegation, with: fromKey)

        let toIdentity = try Secp256k1SigningPrincipal(privateKey: toKey)
        let delegated = try ICPDelegatedIdentity(
            fromPublicKeyDer: fromDer,
            to: toIdentity,
            chain: [signed]
        )

        XCTAssertEqual(delegated.publicKeyDer, fromDer)
        XCTAssertEqual(delegated.delegationChain, [signed])
    }

    func testInitThrowsOnInvalidSignature() throws {
        let fromKey = P256.Signing.PrivateKey()
        let toKey = P256.Signing.PrivateKey()

        let fromDer = try TestKeyDer.p256PublicKeyDer(fromKey.publicKey)
        let toDer = try TestKeyDer.p256PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestKeyDer.signDelegation(delegation, with: toKey) // wrong signer

        let toIdentity = try P256SigningPrincipal(privateKey: toKey)

        XCTAssertThrowsError(
            try ICPDelegatedIdentity(fromPublicKeyDer: fromDer, to: toIdentity, chain: [signed])
        ) { error in
            XCTAssertEqual(error as? ICPDelegatedIdentity.Error, .invalidSignature)
        }
    }

    func testInitThrowsOnInvalidDerPublicKey() throws {
        let toKey = P256.Signing.PrivateKey()
        let toDer = try TestKeyDer.p256PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = ICPSignedDelegation(delegation: delegation, signature: Data([0x01]))
        let invalidDer = try PotentASN1.ASN1Serialization.der(from: .sequence([.integer(1)]))

        let toIdentity = try P256SigningPrincipal(privateKey: toKey)

        XCTAssertThrowsError(
            try ICPDelegatedIdentity(fromPublicKeyDer: invalidDer, to: toIdentity, chain: [signed])
        ) { error in
            XCTAssertEqual(error as? ICPDelegatedIdentity.Error, .invalidDerPublicKey)
        }
    }

    func testInitThrowsOnUnsupportedAlgorithm() throws {
        let toKey = P256.Signing.PrivateKey()
        let toDer = try TestKeyDer.p256PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = ICPSignedDelegation(delegation: delegation, signature: Data([0x01]))

        let unsupportedDer = try TestKeyDer.customDerPublicKey(
            algorithmOid: [1, 2, 3, 4],
            keyBytes: Data([0x04] + Array(repeating: 0x00, count: 64))
        )

        let toIdentity = try P256SigningPrincipal(privateKey: toKey)

        XCTAssertThrowsError(
            try ICPDelegatedIdentity(fromPublicKeyDer: unsupportedDer, to: toIdentity, chain: [signed])
        ) { error in
            XCTAssertEqual(error as? ICPDelegatedIdentity.Error, .unsupportedAlgorithm)
        }
    }

    func testInitThrowsOnSigningKeyMismatch() throws {
        let fromKey = P256.Signing.PrivateKey()
        let toKey = P256.Signing.PrivateKey()
        let otherKey = P256.Signing.PrivateKey()

        let fromDer = try TestKeyDer.p256PublicKeyDer(fromKey.publicKey)
        let otherDer = try TestKeyDer.p256PublicKeyDer(otherKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: otherDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestKeyDer.signDelegation(delegation, with: fromKey)

        let toIdentity = try P256SigningPrincipal(privateKey: toKey)

        XCTAssertThrowsError(
            try ICPDelegatedIdentity(fromPublicKeyDer: fromDer, to: toIdentity, chain: [signed])
        ) { error in
            XCTAssertEqual(error as? ICPDelegatedIdentity.Error, .signingKeyMismatch)
        }
    }

    func testDelegationChainAppendsBaseChain() throws {
        let fromKey = P256.Signing.PrivateKey()
        let toKey = P256.Signing.PrivateKey()

        let fromDer = try TestKeyDer.p256PublicKeyDer(fromKey.publicKey)
        let toDer = try TestKeyDer.p256PublicKeyDer(toKey.publicKey)

        let delegation = ICPDelegation(
            pubkey: toDer,
            expiration: 1_000_000_000_000_000_000
        )
        let signed = try TestKeyDer.signDelegation(delegation, with: fromKey)

        let baseDelegation = ICPDelegation(
            pubkey: Data([0x01, 0x02]),
            expiration: 1_000_000_000_000_000_000
        )
        let baseSigned = ICPSignedDelegation(delegation: baseDelegation, signature: Data([0x03]))

        let toIdentity = try P256SigningPrincipal(privateKey: toKey, delegationChain: [baseSigned])
        let delegated = try ICPDelegatedIdentity(
            fromPublicKeyDer: fromDer,
            to: toIdentity,
            chain: [signed]
        )

        XCTAssertEqual(delegated.delegationChain, [baseSigned, signed])
    }
}

private final class P256SigningPrincipal: ICPSigningPrincipal, ICPDerPublicKeyProvider, ICPDelegationProvider {
    let principal: ICPPrincipal
    let rawPublicKey: Data
    let publicKeyDer: Data
    let delegationChain: [ICPSignedDelegation]

    private let privateKey: P256.Signing.PrivateKey

    init(privateKey: P256.Signing.PrivateKey, delegationChain: [ICPSignedDelegation] = []) throws {
        self.privateKey = privateKey
        self.rawPublicKey = privateKey.publicKey.x963Representation
        self.publicKeyDer = try TestKeyDer.p256PublicKeyDer(privateKey.publicKey)
        self.principal = ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: publicKeyDer)
        self.delegationChain = delegationChain
    }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        let domainSeparated = domain.domainSeparatedData(message)
        let signature = try privateKey.signature(for: domainSeparated)
        return signature.derRepresentation
    }
}

private final class Ed25519SigningPrincipal: ICPSigningPrincipal, ICPDerPublicKeyProvider, ICPDelegationProvider {
    let principal: ICPPrincipal
    let rawPublicKey: Data
    let publicKeyDer: Data
    let delegationChain: [ICPSignedDelegation] = []

    private let privateKey: Curve25519.Signing.PrivateKey

    init(privateKey: Curve25519.Signing.PrivateKey) throws {
        self.privateKey = privateKey
        self.rawPublicKey = privateKey.publicKey.rawRepresentation
        self.publicKeyDer = try TestKeyDer.ed25519PublicKeyDer(privateKey.publicKey)
        self.principal = ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: publicKeyDer)
    }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        let domainSeparated = domain.domainSeparatedData(message)
        return try privateKey.signature(for: domainSeparated)
    }
}

private final class Secp256k1SigningPrincipal: ICPSigningPrincipal, ICPDerPublicKeyProvider, ICPDelegationProvider {
    let principal: ICPPrincipal
    let rawPublicKey: Data
    let publicKeyDer: Data
    let delegationChain: [ICPSignedDelegation] = []

    private let privateKey: TestSecp256k1.PrivateKey

    init(privateKey: TestSecp256k1.PrivateKey) throws {
        self.privateKey = privateKey
        self.rawPublicKey = privateKey.publicKeyUncompressed
        self.publicKeyDer = try ICPCryptography.der(uncompressedEcPublicKey: rawPublicKey)
        self.principal = ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: publicKeyDer)
    }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        let domainSeparated = domain.domainSeparatedData(message)
        return try TestSecp256k1.sign(message: domainSeparated, with: privateKey)
    }
}

private enum TestKeyDer {
    static let ecPublicKeyOid: [UInt64] = [1, 2, 840, 10045, 2, 1]
    static let prime256v1Oid: [UInt64] = [1, 2, 840, 10045, 3, 1, 7]
    static let ed25519Oid: [UInt64] = [1, 3, 101, 112]

    static func p256PublicKeyDer(_ publicKey: P256.Signing.PublicKey) throws -> Data {
        try PotentASN1.ASN1Serialization.der(from: .sequence([
            .sequence([
                .objectIdentifier(ecPublicKeyOid),
                .objectIdentifier(prime256v1Oid)
            ]),
            .bitString(0, publicKey.x963Representation)
        ]))
    }

    static func signDelegation(_ delegation: ICPDelegation, with key: P256.Signing.PrivateKey) throws -> ICPSignedDelegation {
        let message = try delegation.signable()
        let signature = try key.signature(for: message)
        return ICPSignedDelegation(delegation: delegation, signature: signature.derRepresentation)
    }

    static func ed25519PublicKeyDer(_ publicKey: Curve25519.Signing.PublicKey) throws -> Data {
        try PotentASN1.ASN1Serialization.der(from: .sequence([
            .sequence([
                .objectIdentifier(ed25519Oid)
            ]),
            .bitString(0, publicKey.rawRepresentation)
        ]))
    }

    static func customDerPublicKey(algorithmOid: [UInt64], keyBytes: Data) throws -> Data {
        try PotentASN1.ASN1Serialization.der(from: .sequence([
            .sequence([
                .objectIdentifier(algorithmOid)
            ]),
            .bitString(0, keyBytes)
        ]))
    }

    static func signDelegation(_ delegation: ICPDelegation, with key: Curve25519.Signing.PrivateKey) throws -> ICPSignedDelegation {
        let message = try delegation.signable()
        let signature = try key.signature(for: message)
        return ICPSignedDelegation(delegation: delegation, signature: signature)
    }
}

private enum TestSecp256k1 {
    struct PrivateKey {
        let bytes: Data
        let publicKeyUncompressed: Data
    }

    static func generatePrivateKey() throws -> PrivateKey {
        let privateKey = try randomPrivateKey()
        let publicKey = try derivePublicKey(from: privateKey)
        return PrivateKey(bytes: privateKey, publicKeyUncompressed: publicKey)
    }

    static func signDelegation(_ delegation: ICPDelegation, with key: PrivateKey) throws -> ICPSignedDelegation {
        let message = try delegation.signable()
        let signature = try sign(message: message, with: key)
        return ICPSignedDelegation(delegation: delegation, signature: signature)
    }

    static func sign(message: Data, with key: PrivateKey) throws -> Data {
        let hash = ICPCryptography.sha256(message)
        var signature = secp256k1_ecdsa_signature()
        let status = key.bytes.withUnsafeBytes { keyBuffer -> Int32 in
            hash.withUnsafeBytes { hashBuffer -> Int32 in
                secp256k1_ecdsa_sign(
                    secp256k1.Context.raw,
                    &signature,
                    hashBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    keyBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    nil,
                    nil
                )
            }
        }
        guard status == 1 else {
            throw Secp256k1Error.signFailed
        }

        var output = Data(count: 72)
        var outputLen = output.count
        let exportStatus = output.withUnsafeMutableBytes { outputBuffer -> Int32 in
            secp256k1_ecdsa_signature_serialize_der(
                secp256k1.Context.raw,
                outputBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                &outputLen,
                &signature
            )
        }
        guard exportStatus == 1 else {
            throw Secp256k1Error.signFailed
        }

        return output.prefix(outputLen)
    }

    private static func randomPrivateKey() throws -> Data {
        var key = Data(count: 32)
        var isValid = false
        while !isValid {
            let byteCount = key.count
            _ = key.withUnsafeMutableBytes { buffer in
                SecRandomCopyBytes(kSecRandomDefault, byteCount, buffer.baseAddress!)
            }
            isValid = key.withUnsafeBytes { buffer -> Bool in
                secp256k1_ec_seckey_verify(
                    secp256k1.Context.raw,
                    buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
                ) == 1
            }
        }
        return key
    }

    private static func derivePublicKey(from privateKey: Data) throws -> Data {
        var publicKey = secp256k1_pubkey()
        let status = privateKey.withUnsafeBytes { buffer -> Int32 in
            secp256k1_ec_pubkey_create(
                secp256k1.Context.raw,
                &publicKey,
                buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
            )
        }
        guard status == 1 else {
            throw Secp256k1Error.keyGenerationFailed
        }

        var output = Data(count: 65)
        var outputLen = output.count
        let exportStatus = output.withUnsafeMutableBytes { outputBuffer -> Int32 in
            secp256k1_ec_pubkey_serialize(
                secp256k1.Context.raw,
                outputBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                &outputLen,
                &publicKey,
                UInt32(SECP256K1_EC_UNCOMPRESSED)
            )
        }
        guard exportStatus == 1 else {
            throw Secp256k1Error.keyGenerationFailed
        }
        return output.prefix(outputLen)
    }

    enum Secp256k1Error: Error {
        case keyGenerationFailed
        case signFailed
    }
}
