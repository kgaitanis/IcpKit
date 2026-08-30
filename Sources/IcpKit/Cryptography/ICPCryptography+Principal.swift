//
//  SelfAuthenticatingId.swift
//
//  Created by Konstantinos Gaitanis on 25.04.23.
//

import Foundation

public extension ICPCryptography {
    /// Principal with Self-Authenticating ID
    /// These have the form H(ec_public_key) · 0x02 (29 bytes).
    /// ec_public_key in raw uncompressed form (65 bytes) 0x04·X·Y
    static func selfAuthenticatingPrincipal(uncompressedPublicKey publicKey: Data) throws -> ICPPrincipal {
        let serialized = try ICPCryptography.der(uncompressedEcPublicKey: publicKey)
        let hash = ICPCryptography.sha224(serialized)
        let bytes = hash + Data([0x02])
        return ICPPrincipal(bytes)
    }

    /// Principal with Self-Authenticating ID from a DER-encoded public key.
    /// These have the form H(der_public_key) · 0x02 (29 bytes).
    static func selfAuthenticatingPrincipal(derPublicKey publicKey: Data) -> ICPPrincipal {
        let hash = ICPCryptography.sha224(publicKey)
        let bytes = hash + Data([0x02])
        return ICPPrincipal(bytes)
    }
}
