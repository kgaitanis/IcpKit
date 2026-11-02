import Foundation

/// A validated root-to-leaf delegation chain backed by a signing identity.
/// Supports plain secp256k1, P-256 and Ed25519 signatures only.
public final class ICPDelegatedIdentity: ICPSigningPrincipal {
    public enum Error: Swift.Error, Equatable {
        case signingKeyMismatch
        case invalidSignature
        case expiredDelegation
        case repeatedPublicKey
        case chainTooLong
        case tooManyTargets
        case missingCanister
        case targetNotAllowed
    }

    public let publicKey: ICPPublicKey
    public var rawPublicKey: Data { publicKey.rawRepresentation }
    /// Cached hash-derived identifier; the public key itself is stored only once.
    public let principal: ICPPrincipal
    public let delegationChain: [ICPSignedDelegation]

    private let signingIdentity: any ICPSigningPrincipal
    private let now: @Sendable () -> UInt64

    public convenience init(fromPublicKeyDer publicKeyDer: Data, to principal: any ICPSigningPrincipal, chain: [ICPSignedDelegation]) throws {
        try self.init(fromPublicKeyDer: publicKeyDer, to: principal, chain: chain, now: Self.currentTime)
    }

    /// Internal clock injection keeps expiry boundary tests deterministic.
    init(fromPublicKeyDer publicKeyDer: Data, to principal: any ICPSigningPrincipal, chain: [ICPSignedDelegation], now: @escaping @Sendable () -> UInt64) throws {
        let root = try ICPPublicKey(derRepresentation: publicKeyDer)
        let signerKey = try principal.publicKey
        let inherited = principal.delegationChain
        let combined = chain + inherited
        guard combined.count <= 20 else { throw Error.chainTooLong }

        // The supplied prefix must end at the wrapped identity's root key.
        let endpoint = try chain.last.map { try ICPPublicKey(derRepresentation: $0.delegation.pubkey) } ?? root
        guard endpoint == signerKey else { throw Error.signingKeyMismatch }
        try Self.validateChain(combined, root: root)
        try Self.validateExpiration(combined, now: now())

        self.publicKey = root
        self.principal = try ICPPrincipal(publicKey: root)
        self.signingIdentity = principal
        self.delegationChain = combined
        self.now = now
    }

    public func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        try Self.validateExpiration(delegationChain, now: now())
        let signature = try await signingIdentity.sign(message, domain: domain)
        // An arbitrary conformer may change its chain or signing key after construction.
        // Verify the returned signature against our immutable chain snapshot.
        let leaf = try delegationChain.last.map { try ICPPublicKey(derRepresentation: $0.delegation.pubkey) } ?? publicKey
        try ICPCryptography.verify(signature: signature, message: domain.domainSeparatedData(message), publicKey: leaf)
        try Self.validateExpiration(delegationChain, now: now())
        return signature
    }

    static func currentTime() -> UInt64 {
        UInt64(max(0, Date.now.timeIntervalSince1970) * 1_000_000_000)
    }

    static func validateExpiration(_ chain: [ICPSignedDelegation], now: UInt64) throws {
        guard chain.allSatisfy({ $0.delegation.expiration > now }) else {
            throw Error.expiredDelegation
        }
    }

    static func validateTargets(_ chain: [ICPSignedDelegation], canister: ICPPrincipal?) throws {
        for signed in chain {
            guard let targets = signed.delegation.targets else { continue }
            guard targets.count <= 1_000 else { throw Error.tooManyTargets }
            guard let canister else { throw Error.missingCanister }
            guard targets.contains(where: { $0.bytes == canister.bytes }) else { throw Error.targetNotAllowed }
        }
    }

    private static func validateChain(_ chain: [ICPSignedDelegation], root: ICPPublicKey) throws {
        var key = root
        var seen = [root]
        for signed in chain {
            guard (signed.delegation.targets?.count ?? 0) <= 1_000 else { throw Error.tooManyTargets }
            let next = try ICPPublicKey(derRepresentation: signed.delegation.pubkey)
            guard !seen.contains(next) else { throw Error.repeatedPublicKey }
            do {
                try ICPCryptography.verify(signature: signed.signature, message: signed.delegation.signable(), publicKey: key)
            } catch {
                throw Error.invalidSignature
            }
            seen.append(next)
            key = next
        }
    }
}
