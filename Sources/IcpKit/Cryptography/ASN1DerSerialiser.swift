import Foundation
@preconcurrency import PotentASN1

// https://www.ibm.com/docs/en/zos/2.1.0?topic=programming-object-identifiers
private enum ObjectIdentifiers {
    // The ICP interface specification defines these OIDs for DER-encoded BLS keys:
    // 1.3.6.1.4.1.44668.5.3.1.2.1 identifies the algorithm; 1.3.6.1.4.1.44668.5.3.2.1 identifies the curve.
    // https://docs.internetcomputer.org/references/ic-interface-spec/certification/
    static let blsPublicKey: ASN1 = .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 1, 2, 1])
    static let blsCurve: ASN1 = .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 2, 1])
}

extension ICPCryptography {
    enum DERSerialisationError: Error {
        case invalidEcPublicKey
        case invalidBlsPublicKey
    }
    /// Extracts a raw BLS key from a canonical DER SubjectPublicKeyInfo value.
    static func rawBlsPublicKey(fromDER data: Data) throws -> Data {
        let values = try ASN1Serialization.asn1(fromDER: data)
        guard values.count == 1,
              case .sequence(let fields) = values[0], fields.count == 2,
              case .sequence(let identifiers) = fields[0],
              identifiers == [ObjectIdentifiers.blsPublicKey, ObjectIdentifiers.blsCurve],
              case .bitString(let bitCount, let key) = fields[1],
              key.count == 96, bitCount == 96 * 8 else {
            throw DERSerialisationError.invalidBlsPublicKey
        }
        // Reject noncanonical lengths or encodings accepted by the ASN.1 reader.
        guard try ASN1Serialization.der(from: values) == data else {
            throw DERSerialisationError.invalidBlsPublicKey
        }
        return key
    }

    /// Compatibility entry point for uncompressed secp256k1 public keys.
    static func der(uncompressedEcPublicKey publicKey: Data) throws -> Data {
        do {
            return try ICPPublicKey(rawRepresentation: publicKey, algorithm: .secp256k1).derRepresentation
        } catch {
            throw DERSerialisationError.invalidEcPublicKey
        }
    }

    /// Decodes and validates a supported DER SubjectPublicKeyInfo public key.
    /// Use ICPPublicKey(derRepresentation:) when the algorithm is also needed.
    public static func decode(derEncodedPublicKey: Data) throws -> Data {
        try ICPPublicKey(derRepresentation: derEncodedPublicKey).rawRepresentation
    }
}
