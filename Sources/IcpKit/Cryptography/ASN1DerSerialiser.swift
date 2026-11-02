//
//  ASN1DerSerializer.swift
//
//  Created by Konstantinos Gaitanis on 20.04.23.
//

import Foundation
@preconcurrency import PotentASN1

// https://www.ibm.com/docs/en/zos/2.1.0?topic=programming-object-identifiers
private enum ObjectIdentifiers {
    // The ICP interface specification defines these OIDs for DER-encoded BLS keys:
    // 1.3.6.1.4.1.44668.5.3.1.2.1 identifies the algorithm; 1.3.6.1.4.1.44668.5.3.2.1 identifies the curve.
    // https://docs.internetcomputer.org/references/ic-interface-spec/certification/
    static let blsPublicKey: ASN1 = .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 1, 2, 1])
    static let blsCurve: ASN1 = .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 2, 1])
    static let ecPublicKey: ASN1 = .objectIdentifier([1, 2, 840, 10045, 2, 1])  // Asymmetric Encryption Algorithms: ECC (ecPublicKey)
    static let secp256k1: ASN1 = .objectIdentifier([1, 3, 132, 0, 10])          // ECC Name Curves: Secp256k1
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

    static func der(uncompressedEcPublicKey publicKey: Data) throws -> Data {
        guard publicKey.count == 65,
              publicKey.first == 0x04 else {
            throw DERSerialisationError.invalidEcPublicKey
        }
        let encoded = try PotentASN1.ASN1Serialization.der(from:
            .sequence([
                .sequence([
                    ObjectIdentifiers.ecPublicKey,
                    ObjectIdentifiers.secp256k1
                ]),
                .bitString(0, publicKey)    // not sure why we pass 0 here
            ])
        )
        return encoded
    }
}
