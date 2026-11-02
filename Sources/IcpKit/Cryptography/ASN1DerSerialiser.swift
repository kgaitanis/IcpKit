import Foundation
@preconcurrency import PotentASN1

/// Shared DER SubjectPublicKeyInfo serialization for signing and BLS certificate keys.
enum ASN1DerSerialiser {
    // RFC 5480 §2.1.1 / §2.1.1.1: https://www.rfc-editor.org/rfc/rfc5480
    private static let ecPublicKey: [UInt64] = [1, 2, 840, 10045, 2, 1]
    private static let prime256v1: [UInt64] = [1, 2, 840, 10045, 3, 1, 7]
    // SEC 2 §2.4.1: https://www.secg.org/sec2-v2.pdf
    private static let secp256k1: [UInt64] = [1, 3, 132, 0, 10]
    // RFC 8410 §3: https://www.rfc-editor.org/rfc/rfc8410
    private static let ed25519: [UInt64] = [1, 3, 101, 112]

    // ICP certificate keys use separate algorithm and curve identifiers.
    private static let blsPublicKey: [UInt64] = [1, 3, 6, 1, 4, 1, 44668, 5, 3, 1, 2, 1]
    private static let blsCurve: [UInt64] = [1, 3, 6, 1, 4, 1, 44668, 5, 3, 2, 1]

    static func encode(_ key: ICPPublicKey) throws -> Data {
        let identifiers: [ASN1]
        switch key.algorithm {
        case .secp256k1:
            identifiers = [.objectIdentifier(ecPublicKey), .objectIdentifier(secp256k1)]
        case .p256:
            identifiers = [.objectIdentifier(ecPublicKey), .objectIdentifier(prime256v1)]
        case .ed25519:
            identifiers = [.objectIdentifier(ed25519)]
        }
        return try encodeSubjectPublicKeyInfo(identifiers: identifiers, bytes: key.rawRepresentation)
    }

    static func decode(_ der: Data) throws -> ICPPublicKey {
        do {
            let (identifiers, bytes) = try decodeSubjectPublicKeyInfo(der, invalidKey: ICPPublicKey.Error.invalidDerPublicKey)
            guard let oid = identifiers.first?.objectIdentifierValue?.fields else {
                throw ICPPublicKey.Error.invalidDerPublicKey
            }
            let algorithm: ICPPublicKey.Algorithm
            switch oid {
            case ecPublicKey:
                guard identifiers.count == 2,
                      let curve = identifiers[1].objectIdentifierValue?.fields else {
                    throw ICPPublicKey.Error.invalidDerPublicKey
                }
                switch curve {
                case secp256k1: algorithm = .secp256k1
                case prime256v1: algorithm = .p256
                default: throw ICPPublicKey.Error.unsupportedAlgorithm
                }
            case ed25519:
                guard identifiers.count == 1 else { throw ICPPublicKey.Error.invalidDerPublicKey }
                algorithm = .ed25519
            default:
                throw ICPPublicKey.Error.unsupportedAlgorithm
            }
            return try ICPPublicKey(rawRepresentation: bytes, algorithm: algorithm)
        } catch let error as ICPPublicKey.Error {
            throw error
        } catch {
            throw ICPPublicKey.Error.invalidDerPublicKey
        }
    }

    static func rawBlsPublicKey(fromDER data: Data) throws -> Data {
        let error = ICPCryptography.DERSerialisationError.invalidBlsPublicKey
        let (identifiers, bytes) = try decodeSubjectPublicKeyInfo(data, invalidKey: error)
        guard identifiers == [.objectIdentifier(blsPublicKey), .objectIdentifier(blsCurve)],
              bytes.count == 96 else {
            throw error
        }
        return bytes
    }

    private static func encodeSubjectPublicKeyInfo(identifiers: [ASN1], bytes: Data) throws -> Data {
        try ASN1Serialization.der(from: .sequence([
            .sequence(identifiers),
            .bitString(bytes.count * 8, bytes)
        ]))
    }

    /// Validates the shared SPKI structure and requires canonical, byte-aligned DER.
    private static func decodeSubjectPublicKeyInfo(_ data: Data, invalidKey: any Error) throws -> (identifiers: [ASN1], bytes: Data) {
        let values = try ASN1Serialization.asn1(fromDER: data)
        guard values.count == 1,
              case .sequence(let fields) = values[0], fields.count == 2,
              case .sequence(let identifiers) = fields[0],
              case .bitString(let bitCount, let bytes) = fields[1],
              bitCount == bytes.count * 8 else {
            throw invalidKey
        }
        // Re-encoding rejects noncanonical lengths, trailing bytes, and alternate encodings.
        guard try encodeSubjectPublicKeyInfo(identifiers: identifiers, bytes: bytes) == data else {
            throw invalidKey
        }
        return (identifiers, bytes)
    }
}

extension ICPCryptography {
    enum DERSerialisationError: Error {
        case invalidEcPublicKey
        case invalidBlsPublicKey
    }

    /// Extracts a raw BLS key from a canonical DER SubjectPublicKeyInfo value.
    static func rawBlsPublicKey(fromDER data: Data) throws -> Data {
        try ASN1DerSerialiser.rawBlsPublicKey(fromDER: data)
    }

    /// Compatibility entry point for uncompressed secp256k1 public keys.
    static func der(uncompressedEcPublicKey publicKey: Data) throws -> Data {
        do {
            return try ASN1DerSerialiser.encode(ICPPublicKey(rawRepresentation: publicKey, algorithm: .secp256k1))
        } catch {
            throw DERSerialisationError.invalidEcPublicKey
        }
    }

    /// Decodes and validates a supported DER SubjectPublicKeyInfo public key.
    /// Use ICPPublicKey(derRepresentation:) when the algorithm is also needed.
    ///
    /// - Parameter derEncodedPublicKey: Canonical DER SubjectPublicKeyInfo containing
    ///   a secp256k1, P-256, or Ed25519 key.
    /// - Returns: Uncompressed 65-byte EC key bytes or 32 raw Ed25519 key bytes.
    /// - Throws: `ICPPublicKey.Error` if the DER, algorithm, or public key is invalid.
    public static func decode(derEncodedPublicKey: Data) throws -> Data {
        try ASN1DerSerialiser.decode(derEncodedPublicKey).rawRepresentation
    }
}
