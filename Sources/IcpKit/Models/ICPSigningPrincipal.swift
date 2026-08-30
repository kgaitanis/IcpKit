//
//  ICPSigningPrincipal.swift
//
//  Created by Konstantinos Gaitanis on 15.05.23.
//

import Foundation

public protocol ICPSigningPrincipal: Sendable {
    var principal: ICPPrincipal { get }
    var rawPublicKey: Data { get }
    
    /// All implementations of this method must ultimately call `ICPCryptography.ellipticSign` with the appropriate private key and return the result
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data
}

public extension ICPSigningPrincipal {
    /// Sign a delegation to let another key be used to authenticate as this principal.
    func signDelegation(_ delegation: ICPDelegation) async throws -> Data {
        let requestId = try delegation.requestId()
        return try await sign(requestId, domain: "ic-request-auth-delegation")
    }
}
