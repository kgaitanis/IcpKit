//
//  ICPDelegation.swift
//

import Foundation
import Candid

/// A delegation from one key to another.
/// If key A signs a delegation containing key B, then key B may be used to authenticate
/// as key A's corresponding principal.
public struct ICPDelegation: Codable, Equatable {
    /// The delegated-to key (DER-encoded public key).
    public let pubkey: Data
    /// A nanosecond timestamp after which this delegation is no longer valid.
    public let expiration: UInt64
    /// If present, this delegation only applies to requests sent to one of these canisters.
    public let targets: [ICPPrincipal]?

    public init(pubkey: Data, expiration: UInt64, targets: [ICPPrincipal]? = nil) {
        self.pubkey = pubkey
        self.expiration = expiration
        self.targets = targets
    }

    private enum CodingKeys: String, CodingKey {
        case pubkey
        case expiration
        case targets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pubkey = try container.decode(Data.self, forKey: .pubkey)
        self.expiration = try container.decode(UInt64.self, forKey: .expiration)
        self.targets = try container.decodeIfPresent([ICPPrincipal].self, forKey: .targets)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pubkey, forKey: .pubkey)
        try container.encode(expiration, forKey: .expiration)
        try container.encodeIfPresent(targets, forKey: .targets)
    }

    /// Returns the request-id hash of this delegation (used as the message for signing).
    public func requestId() throws -> Data {
        try OrderIndependentHasher.orderIndependentHash(self)
    }

    /// Returns the domain-separated signable bytes for this delegation.
    /// Use this only if you are signing arbitrary bytes yourself (not via `ICPSigningPrincipal.sign`).
    public func signable() throws -> Data {
        let hash = try requestId()
        return ICPDomainSeparator("ic-request-auth-delegation").domainSeparatedData(hash)
    }
}

/// A delegation that has been signed by a principal.
public struct ICPSignedDelegation: Codable, Equatable {
    public let delegation: ICPDelegation
    public let signature: Data

    public init(delegation: ICPDelegation, signature: Data) {
        self.delegation = delegation
        self.signature = signature
    }
}

/// Provides a chain of delegations to include in the request envelope.
public protocol ICPDelegationProvider {
    var delegationChain: [ICPSignedDelegation] { get }
}

/// Provides a DER-encoded public key.
public protocol ICPDerPublicKeyProvider {
    var publicKeyDer: Data { get }
}
