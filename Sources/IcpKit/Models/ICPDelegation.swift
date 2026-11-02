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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard !container.contains(.permissions) else {
            throw DecodingError.dataCorruptedError(forKey: .permissions, in: container, debugDescription: "Delegation permissions are not supported.")
        }
        self.pubkey = try container.decode(Data.self, forKey: .pubkey)
        self.expiration = try container.decode(UInt64.self, forKey: .expiration)
        self.targets = try container.decodeIfPresent([Data].self, forKey: .targets)?.map { ICPPrincipal($0) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pubkey, forKey: .pubkey)
        try container.encode(expiration, forKey: .expiration)
        try container.encodeIfPresent(targets?.map(\.bytes), forKey: .targets)
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
public struct ICPSignedDelegation: Codable, Equatable, Sendable {
    public let delegation: ICPDelegation
    public let signature: Data

    public init(delegation: ICPDelegation, signature: Data) {
        self.delegation = delegation
        self.signature = signature
    }
}
