import Foundation
import CryptoKit
import Testing
import secp256k1
@preconcurrency import PotentASN1
@testable import IcpKit

struct ICPDelegatedIdentityTests {
    @Test func validChainsForAllAlgorithms() async throws {
        for algorithm in [ICPPublicKey.Algorithm.p256, .ed25519, .secp256k1] {
            try await checkValidChain(algorithm: algorithm)
        }
    }

    private func checkValidChain(algorithm: ICPPublicKey.Algorithm) async throws {
        let root = try DelegationTestSigner(algorithm: algorithm, seed: 1)
        let leaf = try DelegationTestSigner(algorithm: algorithm, seed: 2)
        let signed = try await root.delegate(to: leaf.publicKey)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: leaf, chain: [signed])
        #expect(identity.rawPublicKey == root.rawPublicKey)
        #expect(identity.principal == root.principal)
        #expect(identity.delegationChain == [signed])
        let message = Data([1, 2, 3])
        let signature = try await identity.sign(message, domain: "ic-request")
        try ICPCryptography.verify(signature: signature, message: ICPDomainSeparator("ic-request").domainSeparatedData(message), publicKey: leaf.publicKey)
    }

    @Test func nestedMixedChain() async throws {
        let root = try DelegationTestSigner(algorithm: .secp256k1, seed: 1)
        let middle = try DelegationTestSigner(algorithm: .p256, seed: 2)
        let leaf = try DelegationTestSigner(algorithm: .ed25519, seed: 3)
        let first = try await root.delegate(to: middle.publicKey)
        let second = try await middle.delegate(to: leaf.publicKey)
        let inner = try ICPDelegatedIdentity(fromPublicKeyDer: middle.publicKey.derRepresentation, to: leaf, chain: [second])
        let outer = try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: inner, chain: [first])
        #expect(outer.delegationChain == [first, second])
        let content = try ICPRequestBuilder.buildContent(.readState(paths: []), sender: outer.principal)
        let envelope = try await ICPRequestBuilder.buildEnvelope(content, sender: outer)
        #expect(envelope.sender_delegation == [first, second])
        #expect(content.sender == root.principal.bytes)
        let signature = try #require(envelope.sender_sig)
        try ICPCryptography.verify(signature: signature, message: ICPDomainSeparator("ic-request").domainSeparatedData(content.calculateRequestId()), publicKey: leaf.publicKey)
    }

    @Test func invalidSignaturesAndEndpoints() async throws {
        let root = try DelegationTestSigner(seed: 1)
        let leaf = try DelegationTestSigner(seed: 2)
        let other = try DelegationTestSigner(seed: 3)
        let signed = try await root.delegate(to: leaf.publicKey)
        let bad = ICPSignedDelegation(delegation: signed.delegation, signature: Data(repeating: 0, count: 64))
        #expect(throws: ICPDelegatedIdentity.Error.invalidSignature) {
            try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: leaf, chain: [bad])
        }
        #expect(throws: ICPDelegatedIdentity.Error.signingKeyMismatch) {
            try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: other, chain: [signed])
        }
        let inner = DelegationTestSignerWithChain(signer: leaf, delegationChain: [bad])
        #expect(throws: (any Error).self) {
            try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: inner, chain: [signed])
        }
    }

    @Test func emptyChainAndLegacyDefault() async throws {
        let signer = try DelegationTestSigner(algorithm: .secp256k1)
        let legacy: any ICPSigningPrincipal = LegacyDelegationTestSigner(signer: signer)
        #expect(legacy.delegationChain.isEmpty)
        #expect(try legacy.publicKey == signer.publicKey)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: signer.publicKey.derRepresentation, to: legacy, chain: [])
        #expect(identity.delegationChain.isEmpty)
        let signature = try await identity.sign(Data([1]), domain: "ic-request")
        #expect(signature.count == 64)
        #expect(throws: (any Error).self) {
            try ICPDelegatedIdentity(fromPublicKeyDer: Data(), to: signer, chain: [])
        }
    }

    @Test func rejectsCyclesAndLimits() async throws {
        let a = try DelegationTestSigner(seed: 1)
        let b = try DelegationTestSigner(seed: 2)
        let ab = try await a.delegate(to: b.publicKey)
        let ba = try await b.delegate(to: a.publicKey)
        let aa = try await a.delegate(to: a.publicKey)
        #expect(throws: ICPDelegatedIdentity.Error.repeatedPublicKey) {
            try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: a, chain: [ab, ba])
        }
        #expect(throws: ICPDelegatedIdentity.Error.repeatedPublicKey) {
            try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: a, chain: [aa])
        }
        #expect(throws: ICPDelegatedIdentity.Error.chainTooLong) {
            try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: Array(repeating: ab, count: 21))
        }
        let oversized = try await a.delegate(to: b.publicKey, targets: Array(repeating: ICPSystemCanisters.ledger, count: 1001))
        #expect(throws: ICPDelegatedIdentity.Error.tooManyTargets) {
            try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: [oversized])
        }
    }

    @Test func expirationIsRechecked() async throws {
        let a = try DelegationTestSigner(seed: 1)
        let b = try DelegationTestSigner(seed: 2)
        let signed = try await a.delegate(to: b.publicKey, expiration: 100)
        let clock = DelegationTestClock(99)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: [signed], now: { clock.value })
        _ = try await identity.sign(Data([1]), domain: "ic-request")
        clock.value = 100
        await #expect(throws: ICPDelegatedIdentity.Error.expiredDelegation) {
            try await identity.sign(Data([1]), domain: "ic-request")
        }
        #expect(throws: ICPDelegatedIdentity.Error.expiredDelegation) {
            try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: [signed], now: { 100 })
        }
    }

    @Test func targetRestrictions() async throws {
        let a = try DelegationTestSigner(seed: 1)
        let b = try DelegationTestSigner(seed: 2)
        let canister = ICPSystemCanisters.ledger
        let signed = try await a.delegate(to: b.publicKey, targets: [canister])
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: [signed])
        let content = try ICPRequestBuilder.buildContent(.readState(paths: []), sender: identity.principal)
        _ = try await ICPRequestBuilder.buildEnvelope(content, sender: identity, canister: canister)
        await #expect(throws: ICPDelegatedIdentity.Error.missingCanister) {
            _ = try await ICPRequestBuilder.buildEnvelope(content, sender: identity)
        }
        await #expect(throws: ICPDelegatedIdentity.Error.targetNotAllowed) {
            _ = try await ICPRequestBuilder.buildEnvelope(content, sender: identity, canister: ICPPrincipal(Data([4])))
        }
        let empty = try await a.delegate(to: b.publicKey, targets: [])
        let denied = try ICPDelegatedIdentity(fromPublicKeyDer: a.publicKey.derRepresentation, to: b, chain: [empty])
        await #expect(throws: ICPDelegatedIdentity.Error.targetNotAllowed) {
            _ = try await ICPRequestBuilder.buildEnvelope(content, sender: denied, canister: canister)
        }
        for request in [ICPRequestType.query(ICPMethod(canister: canister, methodName: "test")), .call(ICPMethod(canister: canister, methodName: "test"))] {
            let content = try ICPRequestBuilder.buildContent(request, sender: identity.principal)
            _ = try await ICPRequestBuilder.buildEnvelope(content, sender: identity)
        }
    }

    @Test func strictDERForAllAlgorithms() throws {
        for algorithm in [ICPPublicKey.Algorithm.p256, .ed25519, .secp256k1] {
            try checkStrictDER(algorithm: algorithm)
        }
    }

    private func checkStrictDER(algorithm: ICPPublicKey.Algorithm) throws {
        let signer = try DelegationTestSigner(algorithm: algorithm)
        let der = try signer.publicKey.derRepresentation
        #expect(try ICPPublicKey(derRepresentation: der) == signer.publicKey)
        for invalid in [Data(), Data(der.dropLast()), der + Data([0]), der + der] {
            #expect(throws: (any Error).self) { try ICPPublicKey(derRepresentation: invalid) }
        }
        let unknown = try ASN1Serialization.der(from: .sequence([
            .sequence([.objectIdentifier([1, 2, 3, 4])]),
            .bitString(256, Data(repeating: 1, count: 32))
        ]))
        #expect(throws: ICPPublicKey.Error.unsupportedAlgorithm) { try ICPPublicKey(derRepresentation: unknown) }
    }


    @Test func malformedDERStructures() throws {
        let signer = try DelegationTestSigner()
        let oid: ASN1 = .sequence([.objectIdentifier([1, 2, 840, 10045, 2, 1]), .objectIdentifier([1, 2, 840, 10045, 3, 1, 7])])
        let bits = ASN1.bitString(520, signer.rawPublicKey)
        let malformed: [ASN1] = [
            .sequence([oid, bits, .null]),
            .sequence([oid, .bitString(519, signer.rawPublicKey)]),
            .sequence([.sequence([.objectIdentifier([1, 2, 840, 10045, 2, 1])]), bits]),
            .sequence([.sequence([.objectIdentifier([1, 3, 101, 112]), .null]), .bitString(256, Data(repeating: 1, count: 32))]),
            .sequence([oid, .bitString(264, Data([2]) + Data(repeating: 1, count: 32))]),
            .sequence([oid, .bitString(520, Data([4]) + Data(repeating: 0, count: 64))])
        ]
        for value in malformed {
            let der = try ASN1Serialization.der(from: value)
            #expect(throws: (any Error).self) { try ICPPublicKey(derRepresentation: der) }
        }
        // Long-form length for a short sequence is not canonical DER.
        let der = try signer.publicKey.derRepresentation
        let noncanonical = Data([0x30, 0x81, der[1]]) + der.dropFirst(2)
        #expect(throws: (any Error).self) { try ICPPublicKey(derRepresentation: noncanonical) }
    }

    @Test func maximumLimitsAreAccepted() async throws {
        let signers = try (1...21).map { try DelegationTestSigner(algorithm: .ed25519, seed: UInt8($0)) }
        var chain: [ICPSignedDelegation] = []
        for index in 0..<20 {
            chain.append(try await signers[index].delegate(to: signers[index + 1].publicKey))
        }
        let root = try #require(signers.first)
        let leaf = try #require(signers.last)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: leaf, chain: chain)
        #expect(identity.delegationChain.count == 20)
        _ = try await identity.sign(Data([1]), domain: "ic-request")
        let targets = Array(repeating: ICPSystemCanisters.ledger, count: 1000)
        let signed = try await root.delegate(to: leaf.publicKey, targets: targets)
        _ = try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: leaf, chain: [signed])
    }

    @Test func inheritedSignaturesAreVerified() async throws {
        let root = try DelegationTestSigner(seed: 1)
        let middle = try DelegationTestSigner(seed: 2)
        let leaf = try DelegationTestSigner(seed: 3)
        let first = try await root.delegate(to: middle.publicKey)
        let second = try await middle.delegate(to: leaf.publicKey)
        let bad = ICPSignedDelegation(delegation: second.delegation, signature: Data(repeating: 0, count: 64))
        let wrapped = DelegationTestSignerWithChain(signer: middle, delegationChain: [bad])
        #expect(throws: ICPDelegatedIdentity.Error.invalidSignature) {
            try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: wrapped, chain: [first])
        }
    }

    @Test func expirationDuringSigningIsRejected() async throws {
        let root = try DelegationTestSigner(seed: 1)
        let leaf = try DelegationTestSigner(seed: 2)
        let signed = try await root.delegate(to: leaf.publicKey, expiration: 100)
        let clock = DelegationTestClock(99)
        let delayed = ExpiringDelegationTestSigner(signer: leaf, clock: clock)
        let identity = try ICPDelegatedIdentity(fromPublicKeyDer: root.publicKey.derRepresentation, to: delayed, chain: [signed], now: { clock.value })
        await #expect(throws: ICPDelegatedIdentity.Error.expiredDelegation) {
            _ = try await identity.sign(Data([1]), domain: "ic-request")
        }
    }

    @Test func signatureDomainAndFormat() async throws {
        let signer = try DelegationTestSigner()
        let leaf = try DelegationTestSigner(seed: 2)
        let signed = try await signer.delegate(to: leaf.publicKey)
        let key = try P256.Signing.PublicKey(x963Representation: signer.rawPublicKey)
        let signature = try P256.Signing.ECDSASignature(rawRepresentation: signed.signature)
        #expect(try key.isValidSignature(signature, for: signed.delegation.signable()))
        #expect(try !key.isValidSignature(signature, for: signed.delegation.requestId()))
        #expect(throws: ICPPublicKey.Error.invalidSignature) {
            try ICPCryptography.verify(signature: signature.derRepresentation, message: signed.delegation.signable(), publicKey: signer.publicKey)
        }
    }
}

// The lock protects all access to the clock shared with Sendable signers.
final class DelegationTestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValue: UInt64

    var value: UInt64 {
        get { lock.withLock { storedValue } }
        set { lock.withLock { storedValue = newValue } }
    }

    init(_ value: UInt64) { self.storedValue = value }
}

/// Deterministic fixture keys; no test secrets are used outside this suite.
struct DelegationTestSigner: ICPSigningPrincipal {
    let publicKey: ICPPublicKey
    let principal: ICPPrincipal
    let secret: Data
    var rawPublicKey: Data { publicKey.rawRepresentation }

    init(algorithm: ICPPublicKey.Algorithm = .p256, seed: UInt8 = 1) throws {
        secret = Data(repeating: seed, count: 32)
        let bytes: Data
        switch algorithm {
        case .p256: bytes = try P256.Signing.PrivateKey(rawRepresentation: secret).publicKey.x963Representation
        case .ed25519: bytes = try Curve25519.Signing.PrivateKey(rawRepresentation: secret).publicKey.rawRepresentation
        case .secp256k1:
            var key = secp256k1_pubkey()
            let result = secret.withUnsafeBytes { buffer -> Int32 in
                guard let address = buffer.baseAddress else { return 0 }
                return secp256k1_ec_pubkey_create(secp256k1.Context.raw, &key, address.assumingMemoryBound(to: UInt8.self))
            }
            guard result == 1 else { throw ICPPublicKey.Error.invalidPublicKey }
            var output = Data(count: 65)
            var count = output.count
            let exported = output.withUnsafeMutableBytes { buffer -> Int32 in
                guard let address = buffer.baseAddress else { return 0 }
                return secp256k1_ec_pubkey_serialize(secp256k1.Context.raw, address.assumingMemoryBound(to: UInt8.self), &count, &key, UInt32(SECP256K1_EC_UNCOMPRESSED))
            }
            guard exported == 1 else { throw ICPPublicKey.Error.invalidPublicKey }
            bytes = output
        }
        publicKey = try ICPPublicKey(rawRepresentation: bytes, algorithm: algorithm)
        principal = try ICPPrincipal(publicKey: publicKey)
    }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        let payload = domain.domainSeparatedData(message)
        switch publicKey.algorithm {
        case .p256:
            return try P256.Signing.PrivateKey(rawRepresentation: secret).signature(for: payload).rawRepresentation
        case .ed25519:
            return try Curve25519.Signing.PrivateKey(rawRepresentation: secret).signature(for: payload)
        case .secp256k1:
            return try Data(ICPCryptography.ellipticSign(ICPCryptography.sha256(payload), privateKey: secret).prefix(64))
        }
    }

    func delegate(to key: ICPPublicKey, expiration: UInt64 = 4_000_000_000_000_000_000, targets: [ICPPrincipal]? = nil) async throws -> ICPSignedDelegation {
        let delegation = try ICPDelegation(pubkey: key.derRepresentation, expiration: expiration, targets: targets)
        return try await ICPSignedDelegation(delegation: delegation, signature: signDelegation(delegation))
    }
}

private struct LegacyDelegationTestSigner: ICPSigningPrincipal {
    let signer: DelegationTestSigner
    var principal: ICPPrincipal { signer.principal }
    var rawPublicKey: Data { signer.rawPublicKey }
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        try await signer.sign(message, domain: domain)
    }
}

private struct DelegationTestSignerWithChain: ICPSigningPrincipal {
    let signer: DelegationTestSigner
    let delegationChain: [ICPSignedDelegation]
    var principal: ICPPrincipal { signer.principal }
    var rawPublicKey: Data { signer.rawPublicKey }
    var publicKey: ICPPublicKey { signer.publicKey }
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        try await signer.sign(message, domain: domain)
    }
}

private struct ExpiringDelegationTestSigner: ICPSigningPrincipal {
    let signer: DelegationTestSigner
    let clock: DelegationTestClock
    var publicKey: ICPPublicKey { signer.publicKey }
    var principal: ICPPrincipal { signer.principal }
    var rawPublicKey: Data { signer.rawPublicKey }

    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        let signature = try await signer.sign(message, domain: domain)
        clock.value = 100
        return signature
    }
}
