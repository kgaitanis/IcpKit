//
//  EllipticSign.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation

extension ICPCryptography {
    enum SignError: Error {
        case signFailed
    }
    /// secp256k1
    static func ellipticSign(_ message: any DataProtocol, privateKey: Data) throws -> Data {
        let encrypter = EllipticCurveEncrypterSecp256k1()
        guard var signatureInInternalFormat = encrypter.sign(hash: Data(message), privateKey: privateKey) else {
            throw SignError.signFailed
        }
        var signature = encrypter.export(signature: &signatureInInternalFormat)
        // signature is 65 bytes. last byte is the recid (see https://bitcoin.stackexchange.com/questions/38351/ecdsa-v-r-s-what-is-v)
        // For bitcoin/ethereum signing we add 0x1b to the last byte (recid)
        signature[64] += 0x1b // 27
        return signature
    }
}


/// from package HsCryptoKit.swift
/// https://github.com/horizontalsystems/HsCryptoKit.Swift/blob/main/Sources/HsCryptoKit/EllipticCurveEncrypterSecp256k1.swift
import secp256k1


/// Convenience class over libsecp256k1 methods
private final class EllipticCurveEncrypterSecp256k1 {
    // holds internal state of the c library
    private let context: OpaquePointer
    
    init() {
        context = secp256k1.Context.raw
    }
    
    /// Signs the hash with the private key. Produces signature data structure that can be exported with
    /// export(signature:) method.
    ///
    /// - Parameters:
    ///   - hash: 32-byte (256-bit) hash of the message
    ///   - privateKey: 32-byte private key
    /// - Returns: signature data structure if signing succeeded, otherwise nil.
    func sign(hash: Data, privateKey: Data) -> secp256k1_ecdsa_recoverable_signature? {
        precondition(hash.count == 32, "Hash must be 32 bytes size")
        precondition(privateKey.count == 32, "PrivateKey must be 32 bytes size")
        var signature = secp256k1_ecdsa_recoverable_signature()
        
        let status = privateKey.withUnsafeBytes { key -> Int32 in
            hash.withUnsafeBytes { hash -> Int32 in
                secp256k1_ecdsa_sign_recoverable(context, &signature, hash.baseAddress!.assumingMemoryBound(to: UInt8.self), key.baseAddress!.assumingMemoryBound(to: UInt8.self), nil, nil) }
        }
        return status == 1 ? signature : nil
    }
    
    /// Converts signature data structure to 65 bytes.
    ///
    /// - Parameter signature: signature data structure
    /// - Returns: 65 byte exported signature data.
    func export(signature: inout secp256k1_ecdsa_recoverable_signature) -> Data {
        var output = Data(count: 65)
        var recid = 0 as Int32
        _ = output.withUnsafeMutableBytes { output in
            secp256k1_ecdsa_recoverable_signature_serialize_compact(context, output.baseAddress!.assumingMemoryBound(to: UInt8.self), &recid, &signature)
        }
        
        output[64] = UInt8(recid)
        return output
    }    
}

public extension ICPCryptography {
    /// Verifies an ICP compact (64-byte r || s) signature over SHA-256(message).
    ///
    /// Both low-S and high-S ECDSA signatures are accepted.
    /// - Parameters:
    ///   - signature: A 64-byte compact `r || s` signature without a recovery identifier.
    ///   - message: The bytes to hash with SHA-256 before verification. Include any
    ///     required domain separator; this method does not prepend one.
    ///   - publicKeyUncompressed: An uncompressed 65-byte secp256k1 public key.
    /// - Returns: Whether the signature authenticates the message.
    /// - Throws: `ICPPublicKey.Error.invalidPublicKey` or
    ///   `ICPPublicKey.Error.invalidSignature` if either input cannot be parsed.
    static func verifySecp256k1(signature: Data, message: Data, publicKeyUncompressed: Data) throws -> Bool {
        var publicKey = try parseSecp256k1PublicKey(publicKeyUncompressed)
        var signature = try parseSecp256k1Signature(signature)
        // libsecp256k1 only verifies low-S signatures. Both S forms are valid ECDSA.
        var normalized = secp256k1_ecdsa_signature()
        secp256k1_ecdsa_signature_normalize(secp256k1.Context.raw, &normalized, &signature)
        let hash = sha256(message)
        return hash.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return false }
            return secp256k1_ecdsa_verify(
                secp256k1.Context.raw, &normalized,
                baseAddress.assumingMemoryBound(to: UInt8.self), &publicKey
            ) == 1
        }
    }
}

extension ICPCryptography {
    static func validateSecp256k1PublicKey(_ bytes: Data) throws {
        _ = try parseSecp256k1PublicKey(bytes)
    }

    private static func parseSecp256k1PublicKey(_ bytes: Data) throws -> secp256k1_pubkey {
        guard bytes.count == 65, bytes.first == 4 else { throw ICPPublicKey.Error.invalidPublicKey }
        var key = secp256k1_pubkey()
        let result = bytes.withUnsafeBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return secp256k1_ec_pubkey_parse(
                secp256k1.Context.raw, &key,
                baseAddress.assumingMemoryBound(to: UInt8.self), bytes.count
            )
        }
        guard result == 1 else { throw ICPPublicKey.Error.invalidPublicKey }
        return key
    }

    private static func parseSecp256k1Signature(_ bytes: Data) throws -> secp256k1_ecdsa_signature {
        guard bytes.count == 64 else { throw ICPPublicKey.Error.invalidSignature }
        var signature = secp256k1_ecdsa_signature()
        let result = bytes.withUnsafeBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return secp256k1_ecdsa_signature_parse_compact(
                secp256k1.Context.raw, &signature,
                baseAddress.assumingMemoryBound(to: UInt8.self)
            )
        }
        guard result == 1 else { throw ICPPublicKey.Error.invalidSignature }
        return signature
    }
}
