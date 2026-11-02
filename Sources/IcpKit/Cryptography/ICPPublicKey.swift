import Foundation
import CryptoKit

/// A validated public key. EC keys use uncompressed X9.63 bytes; Ed25519 uses 32 raw bytes.
public struct ICPPublicKey: Equatable, Sendable {
    public enum Algorithm: Sendable {
        case secp256k1
        case p256
        case ed25519
    }

    public enum Error: Swift.Error, Equatable {
        case invalidPublicKey
        case invalidDerPublicKey
        case unsupportedAlgorithm
        case invalidSignature
    }

    public let algorithm: Algorithm
    public let rawRepresentation: Data

    public init(rawRepresentation: Data, algorithm: Algorithm) throws {
        do {
            switch algorithm {
            case .secp256k1:
                try ICPCryptography.validateSecp256k1PublicKey(rawRepresentation)
            case .p256:
                guard rawRepresentation.count == 65, rawRepresentation.first == 4 else {
                    throw Error.invalidPublicKey
                }
                _ = try P256.Signing.PublicKey(x963Representation: rawRepresentation)
            case .ed25519:
                _ = try Curve25519.Signing.PublicKey(rawRepresentation: rawRepresentation)
            }
        } catch {
            throw Error.invalidPublicKey
        }
        self.algorithm = algorithm
        self.rawRepresentation = rawRepresentation
    }

    public init(derRepresentation: Data) throws {
        self = try ASN1DerSerialiser.decode(derRepresentation)
    }

    public var derRepresentation: Data {
        get throws { try ASN1DerSerialiser.encode(self) }
    }
}
