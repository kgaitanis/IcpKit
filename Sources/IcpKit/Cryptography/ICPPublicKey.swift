import Foundation
import CryptoKit

/// A validated public key. EC keys use uncompressed X9.63 bytes; Ed25519 uses 32 raw bytes.
public struct ICPPublicKey: Equatable, Sendable {
    /// A signing algorithm supported by Internet Computer delegation chains.
    public enum Algorithm: Sendable {
        /// ECDSA over secp256k1 with an uncompressed 65-byte public key.
        case secp256k1
        /// ECDSA over NIST P-256 with an uncompressed 65-byte public key.
        case p256
        /// Ed25519 with a 32-byte raw public key.
        case ed25519
    }

    /// Failures encountered while validating keys, decoding DER, or verifying signatures.
    public enum Error: Swift.Error, Equatable {
        /// The raw key is invalid for the selected algorithm.
        case invalidPublicKey
        /// The DER value is malformed, noncanonical, or has an invalid key structure.
        case invalidDerPublicKey
        /// The DER algorithm or elliptic curve identifier is unsupported.
        case unsupportedAlgorithm
        /// The signature is malformed or does not authenticate the message.
        case invalidSignature
    }

    /// The algorithm used to interpret the key and verify signatures.
    public let algorithm: Algorithm
    /// Uncompressed X9.63 bytes for EC keys, or 32 raw bytes for Ed25519.
    public let rawRepresentation: Data

    /// Validates a raw public key for the specified algorithm.
    ///
    /// - Parameters:
    ///   - rawRepresentation: Uncompressed 65-byte EC key or 32-byte Ed25519 key.
    ///   - algorithm: The algorithm associated with the key.
    /// - Throws: `Error.invalidPublicKey` if the bytes are invalid for the algorithm.
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

    /// Decodes a canonical DER SubjectPublicKeyInfo value and validates its public key.
    ///
    /// - Parameter derRepresentation: DER bytes containing a supported signing key.
    /// - Throws: `Error.invalidDerPublicKey`, `Error.unsupportedAlgorithm`, or
    ///   `Error.invalidPublicKey` if decoding or key validation fails.
    public init(derRepresentation: Data) throws {
        self = try ASN1DerSerialiser.decode(derRepresentation)
    }

    /// The canonical DER SubjectPublicKeyInfo representation, including algorithm identifiers.
    ///
    /// - Throws: An ASN.1 serialization error if the key cannot be encoded.
    public var derRepresentation: Data {
        get throws { try ASN1DerSerialiser.encode(self) }
    }
}
