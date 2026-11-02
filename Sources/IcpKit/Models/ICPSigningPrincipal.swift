import Foundation

/// An identity that signs domain-separated ICP messages directly or through a delegation chain.
public protocol ICPSigningPrincipal: Sendable {
    /// The principal represented by this identity's root public key.
    var principal: ICPPrincipal { get }
    /// Raw bytes of the root public key (not DER).
    var rawPublicKey: Data { get }
    /// The validated root public key and its algorithm.
    ///
    /// - Throws: An error obtaining or validating the public key.
    var publicKey: ICPPublicKey { get throws }
    /// Ordered root-to-leaf delegations; empty for a direct signer.
    var delegationChain: [ICPSignedDelegation] { get }

    /// Sign the domain-separated message using the final signing key.
    /// Return ICP wire bytes: 64-byte r || s for ECDSA, or an Ed25519 signature.
    ///
    /// - Parameters:
    ///   - message: Message bytes before domain separation.
    ///   - domain: The separator identifying the message's purpose.
    /// - Returns: A 64-byte signature suitable for an ICP request.
    /// - Throws: An implementation-specific signing or delegation validation error.
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data
}

public extension ICPSigningPrincipal {
    /// Compatibility default for existing secp256k1 signers.
    ///
    /// Override this property for other algorithms.
    /// - Throws: `ICPPublicKey.Error.invalidPublicKey` if `rawPublicKey` is invalid.
    var publicKey: ICPPublicKey {
        get throws { try ICPPublicKey(rawRepresentation: rawPublicKey, algorithm: .secp256k1) }
    }

    /// An empty chain for a direct signer; delegated signers must provide their chain.
    var delegationChain: [ICPSignedDelegation] { [] }

    /// Signs a delegation's request ID using the delegation domain separator.
    ///
    /// - Parameter delegation: The delegation to authorize.
    /// - Returns: The signature bytes to store in `ICPSignedDelegation`.
    /// - Throws: An error hashing the delegation or signing its request ID.
    ///   This helper does not validate the delegation's key, expiration, or targets.
    func signDelegation(_ delegation: ICPDelegation) async throws -> Data {
        try await sign(delegation.requestId(), domain: "ic-request-auth-delegation")
    }
}
