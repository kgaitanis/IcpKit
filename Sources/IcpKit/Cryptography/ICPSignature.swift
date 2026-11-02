//
//  ICPSignature.swift
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation
import CryptoKit
import bls12381

public extension ICPCryptography {
    /// https://internetcomputer.org/docs/current/references/ic-interface-spec/#signatures
    /// Signatures are domain separated, which means that every message is prefixed with a byte string that is unique to the purpose of the signature.
    /// The domain separators are prefix-free by construction, as their first byte indicates their length.
    static func ellipticSign(_ message: any DataProtocol, domain: ICPDomainSeparator, with key: Data) throws -> Data {
        let domainSeparatedData = domain.domainSeparatedData(message)
        let hashedMessage = ICPCryptography.sha256(domainSeparatedData)
        let extendedSignature = try ICPCryptography.ellipticSign(hashedMessage, privateKey: key)
        return extendedSignature
    }
    
    static func verifyBlsSignature(message: any DataProtocol, publicKey: any DataProtocol, signature: any DataProtocol) throws {
        switch blsInitializationStatus {
        case 1:
            break
        case -1:
            throw BlsRustError.panic
        default:
            throw BlsRustError.notInstantiated
        }
        try Data(signature).withUnsafeBytes { signaturePointer in
            try Data(message).withUnsafeBytes { messagePointer in
                try Data(publicKey).withUnsafeBytes { publicKeyPointer in
                    let i = bls_verify(signature.count, signaturePointer.baseAddress,
                                       message.count, messagePointer.baseAddress,
                                       publicKey.count, publicKeyPointer.baseAddress)
                    switch i {
                    case 1:
                        break
                    case 0:
                        throw ICPStateCertificateError.invalidSignature
                    default:
                        throw BlsRustError.panic
                    }
                }
            }
        }
    }
    
    private static let blsInitializationStatus = bls_instantiate()
}

/// Unexpected failures in the Rust BLS implementation.
/// Invalid signatures throw `ICPStateCertificateError.invalidSignature`.
public enum BlsRustError: Error, Equatable {
    case notInstantiated
    case panic
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
