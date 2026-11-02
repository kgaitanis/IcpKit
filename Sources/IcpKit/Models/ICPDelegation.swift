//
//  ICPDelegation.swift
//

import Foundation
import Candid

/// A delegation from one key to another.
/// If key A signs a delegation containing key B, then key B may be used to authenticate
/// as key A's corresponding principal.
public struct ICPDelegation: Codable, Equatable, Sendable {
    /// The delegated-to key (DER-encoded public key).
    public let pubkey: Data
    /// A nanosecond timestamp after which this delegation is no longer valid.
    public let expiration: UInt64
    /// If present, this delegation only applies to requests sent to one of these canisters.
    public let targets: [ICPPrincipal]?

    /// Stores a delegation's fields without validating its key, expiration, or targets.
    ///
    /// - Parameters:
    ///   - pubkey: The delegated-to public key as DER SubjectPublicKeyInfo bytes.
    ///   - expiration: Exclusive expiration time in nanoseconds since the Unix epoch.
    ///   - targets: Allowed canisters; `nil` imposes no target restriction, while
    ///     an empty array permits no canisters.
    public init(pubkey: Data, expiration: UInt64, targets: [ICPPrincipal]? = nil) {
        self.pubkey = pubkey
        self.expiration = expiration
        self.targets = targets
    }

    private enum CodingKeys: String, CodingKey {
        case pubkey
        case expiration
        case targets
        case permissions
    }

    /// Decodes a delegation, interpreting target canisters as principal byte blobs.
    ///
    /// - Parameter decoder: The decoder supplying the delegation fields.
    /// - Throws: A decoding error for malformed fields or an unsupported `permissions` field.
    ///   Cryptographic validity and expiration are checked by `ICPDelegatedIdentity`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard !container.contains(.permissions) else {
            throw DecodingError.dataCorruptedError(forKey: .permissions, in: container, debugDescription: "Delegation permissions are not supported.")
        }
        self.pubkey = try container.decode(Data.self, forKey: .pubkey)
        self.expiration = try container.decode(UInt64.self, forKey: .expiration)
        self.targets = try container.decodeIfPresent([Data].self, forKey: .targets)?.map { ICPPrincipal($0) }
    }

    /// Encodes the delegation with target canisters represented as principal byte blobs.
    ///
    /// - Parameter encoder: The encoder receiving the delegation fields.
    /// - Throws: An error from the encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pubkey, forKey: .pubkey)
        try container.encode(expiration, forKey: .expiration)
        try container.encodeIfPresent(targets?.map(\.bytes), forKey: .targets)
    }

    /// Returns the request-id hash of this delegation (used as the message for signing).
    ///
    /// - Returns: The 32-byte order-independent hash of the delegation fields.
    /// - Throws: An error encoding or hashing the delegation.
    public func requestId() throws -> Data {
        try OrderIndependentHasher.orderIndependentHash(self)
    }

    /// Returns the domain-separated signable bytes for this delegation.
    /// Use this only if you are signing arbitrary bytes yourself (not via `ICPSigningPrincipal.sign`).
    ///
    /// - Returns: The `ic-request-auth-delegation` domain separator followed by the request ID.
    /// - Throws: An error calculating the delegation's request ID.
    public func signable() throws -> Data {
        let hash = try requestId()
        return ICPDomainSeparator("ic-request-auth-delegation").domainSeparatedData(hash)
    }
}

/// A delegation that has been signed by a principal.
public struct ICPSignedDelegation: Codable, Equatable, Sendable {
    /// The delegation authenticated by the signature.
    public let delegation: ICPDelegation
    /// A 64-byte compact ECDSA or Ed25519 signature over the delegation's signable bytes.
    public let signature: Data

    /// Pairs a delegation with its signature without performing verification.
    ///
    /// - Parameters:
    ///   - delegation: The delegation signed by the preceding key in the chain.
    ///   - signature: The signature over `delegation.signable()`.
    ///     ECDSA uses compact `r || s` bytes without a recovery identifier.
    public init(delegation: ICPDelegation, signature: Data) {
        self.delegation = delegation
        self.signature = signature
    }
}
