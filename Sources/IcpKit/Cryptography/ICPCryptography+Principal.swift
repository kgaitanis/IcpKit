import Foundation

public extension ICPCryptography {
    /// Compatibility helper for a self-authenticating secp256k1 principal.
    static func selfAuthenticatingPrincipal(uncompressedPublicKey publicKey: Data) throws -> ICPPrincipal {
        try ICPPrincipal(publicKey: ICPPublicKey(rawRepresentation: publicKey, algorithm: .secp256k1))
    }
}
