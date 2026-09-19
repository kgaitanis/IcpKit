//
//  ICPSignature.swift
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation

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
        try BlsSignatureVerifier().verify(message: message, publicKey: publicKey, signature: signature)
    }
}
