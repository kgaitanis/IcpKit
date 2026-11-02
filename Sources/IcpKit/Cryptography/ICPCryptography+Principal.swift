import Foundation

public extension ICPCryptography {
    /// Compatibility helper for a self-authenticating secp256k1 principal.
    ///
    /// - Parameter publicKey: An uncompressed 65-byte secp256k1 public key.
    /// - Returns: SHA-224 of the DER-encoded key followed by the self-authenticating tag.
    /// - Throws: An error validating or DER-encoding the key.
    static func selfAuthenticatingPrincipal(uncompressedPublicKey publicKey: Data) throws -> ICPPrincipal {
        try ICPPrincipal(publicKey: ICPPublicKey(rawRepresentation: publicKey, algorithm: .secp256k1))
    }
}
