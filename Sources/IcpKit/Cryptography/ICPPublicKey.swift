import Foundation
import CryptoKit
@preconcurrency import PotentASN1

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
        self = try ICPPublicKeyCodec.decode(derRepresentation)
    }

    public var derRepresentation: Data {
        get throws { try ICPPublicKeyCodec.encode(self) }
    }
}

/// DER SubjectPublicKeyInfo encoding is centralized here, not in identities.
enum ICPPublicKeyCodec {
    // RFC 5480 §2.1.1 / §2.1.1.1: https://www.rfc-editor.org/rfc/rfc5480
    static let ecPublicKey: [UInt64] = [1, 2, 840, 10045, 2, 1]
    static let prime256v1: [UInt64] = [1, 2, 840, 10045, 3, 1, 7]
    // SEC 2 §2.4.1: https://www.secg.org/sec2-v2.pdf
    static let secp256k1: [UInt64] = [1, 3, 132, 0, 10]
    // RFC 8410 §3: https://www.rfc-editor.org/rfc/rfc8410
    static let ed25519: [UInt64] = [1, 3, 101, 112]

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
        return try ASN1Serialization.der(from: .sequence([
            .sequence(identifiers),
            .bitString(key.rawRepresentation.count * 8, key.rawRepresentation)
        ]))
    }

    static func decode(_ der: Data) throws -> ICPPublicKey {
        do {
            let values = try ASN1Serialization.asn1(fromDER: der)
            guard values.count == 1,
                  case .sequence(let fields) = values[0],
                  fields.count == 2,
                  case .sequence(let identifiers) = fields[0],
                  let oid = identifiers.first?.objectIdentifierValue?.fields,
                  let bits = fields[1].bitStringValue,
                  bits.length == bits.bytes.count * 8 else {
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
            let key = try ICPPublicKey(rawRepresentation: bits.bytes, algorithm: algorithm)
            // Re-encoding rejects noncanonical lengths, trailing bytes, and alternate encodings.
            guard try encode(key) == der else { throw ICPPublicKey.Error.invalidDerPublicKey }
            return key
        } catch let error as ICPPublicKey.Error {
            throw error
        } catch {
            throw ICPPublicKey.Error.invalidDerPublicKey
        }
    }
}

extension ICPCryptography {
    static func verify(signature: Data, message: Data, publicKey: ICPPublicKey) throws {
        guard signature.count == 64 else { throw ICPPublicKey.Error.invalidSignature }
        do {
            let valid: Bool
            switch publicKey.algorithm {
            case .secp256k1:
                valid = try verifySecp256k1(signature: signature, message: message, publicKeyUncompressed: publicKey.rawRepresentation)
            case .p256:
                let key = try P256.Signing.PublicKey(x963Representation: publicKey.rawRepresentation)
                let signature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
                valid = key.isValidSignature(signature, for: message)
            case .ed25519:
                let key = try Curve25519.Signing.PublicKey(rawRepresentation: publicKey.rawRepresentation)
                valid = key.isValidSignature(signature, for: message)
            }
            guard valid else { throw ICPPublicKey.Error.invalidSignature }
        } catch {
            throw ICPPublicKey.Error.invalidSignature
        }
    }
}
