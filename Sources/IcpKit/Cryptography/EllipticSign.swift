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

enum Secp256k1VerifyError: Error {
    case invalidPublicKey
    case invalidSignature
}

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
    
    /// Converts serialized signature into library's signature format. Use it to supply signature to
    /// the publicKey(signature:hash:) method.
    ///
    /// - Parameter signature: serialized 65-byte signature
    /// - Returns: signature structure
    func `import`(signature: Data) -> secp256k1_ecdsa_recoverable_signature {
        precondition(signature.count == 65, "Signature must be 65 byte size")
        var sig = secp256k1_ecdsa_recoverable_signature()
        let recid = Int32(signature[64])
        signature.withUnsafeBytes { input -> Void in
            secp256k1_ecdsa_recoverable_signature_parse_compact(context, &sig, input.baseAddress!.assumingMemoryBound(to: UInt8.self), recid)
        }
        return sig
    }
    
    /// Recovers public key from the signature and the hash. Use import(signature:) to convert signature from bytes.
    /// Use export(publicKey:compressed) to convert recovered public key into bytes.
    ///
    /// - Parameters:
    ///   - signature: signature structure
    ///   - hash: 32-byte (256-bit) hash of a message
    /// - Returns: public key structure or nil, if signature invalid
    func publicKey(signature: inout secp256k1_ecdsa_recoverable_signature, hash: Data) -> secp256k1_pubkey? {
        precondition(hash.count == 32, "Hash must be 32 bytes size")
        
        let bytes = hash.withUnsafeBytes { key in
            [UInt8](UnsafeBufferPointer(start: key.baseAddress!.assumingMemoryBound(to: UInt8.self), count: hash.count))
        }
        
        var outPubKey = secp256k1_pubkey()
        let status = secp256k1_ecdsa_recover(context, &outPubKey, &signature, bytes)
        return status == 1 ? outPubKey : nil
    }
    
    /// Converts public key from library's data structure to bytes
    ///
    /// - Parameters:
    ///   - publicKey: public key structure to convert.
    ///   - compressed: whether public key should be compressed.
    /// - Returns: If compression enabled, public key is 33 bytes size, otherwise it is 65 bytes.
    func export(publicKey: inout secp256k1_pubkey, compressed: Bool) -> Data {
        var output = Data(count: compressed ? 33 : 65)
        var outputLen: Int = output.count
        let compressedFlags = compressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        output.withUnsafeMutableBytes { pointer -> Void in
            secp256k1_ec_pubkey_serialize(context, pointer.baseAddress!.assumingMemoryBound(to: UInt8.self), &outputLen, &publicKey, compressedFlags)
        }
        return output
    }
    
}

public extension ICPCryptography {
    static func verifySecp256k1(signatureDER: Data, message: Data, publicKeyUncompressed: Data) throws -> Bool {
        let context = secp256k1.Context.raw
        var pubKey = secp256k1_pubkey()
        let pubKeyResult = publicKeyUncompressed.withUnsafeBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return secp256k1_ec_pubkey_parse(
                context,
                &pubKey,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                publicKeyUncompressed.count
            )
        }
        guard pubKeyResult == 1 else {
            throw Secp256k1VerifyError.invalidPublicKey
        }

        var signature = secp256k1_ecdsa_signature()
        let signatureResult = signatureDER.withUnsafeBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return secp256k1_ecdsa_signature_parse_der(
                context,
                &signature,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                signatureDER.count
            )
        }
        guard signatureResult == 1 else {
            throw Secp256k1VerifyError.invalidSignature
        }

        let hash = ICPCryptography.sha256(message)
        let verifyResult = hash.withUnsafeBytes { buffer -> Int32 in
            guard let baseAddress = buffer.baseAddress else { return 0 }
            return secp256k1_ecdsa_verify(
                context,
                &signature,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                &pubKey
            )
        }
        return verifyResult == 1
    }
}
