//
//  SimplePrincipal.swift
//
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation
import IcpKit

final class SimplePrincipal: ICPSigningPrincipal {
    let principal: ICPPrincipal
    let rawPublicKey: Data
    private let privateKey: Data
    
    init(privateKey: Data, uncompressedPublicKey: Data) throws {
        principal = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: uncompressedPublicKey)
        rawPublicKey = uncompressedPublicKey
        self.privateKey = privateKey
    }
    
    func sign(_ message: Data, domain: IcpKit.ICPDomainSeparator) async throws -> Data {
        try ICPCryptography.ellipticSign(message, domain: domain, with: privateKey).dropLast()
    }
}
