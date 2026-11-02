import Foundation

public protocol ICPSigningPrincipal: Sendable {
    var principal: ICPPrincipal { get }
    /// Raw bytes of the root public key (not DER).
    var rawPublicKey: Data { get }
    var publicKey: ICPPublicKey { get throws }
    /// Ordered root-to-leaf delegations; empty for a direct signer.
    var delegationChain: [ICPSignedDelegation] { get }

    /// Sign the domain-separated message using the final signing key.
    /// Return ICP wire bytes: 64-byte r || s for ECDSA, or an Ed25519 signature.
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data
}

public extension ICPSigningPrincipal {
    /// Compatibility default for existing secp256k1 signers.
    var publicKey: ICPPublicKey {
        get throws { try ICPPublicKey(rawRepresentation: rawPublicKey, algorithm: .secp256k1) }
    }

    var delegationChain: [ICPSignedDelegation] { [] }

    func signDelegation(_ delegation: ICPDelegation) async throws -> Data {
        try await sign(delegation.requestId(), domain: "ic-request-auth-delegation")
    }
}
