//
//  SimplePrincipal.swift
//  AppIcp
//
//  Created by Konstantinos Gaitanis on 21.11.23.
//

import Foundation
import IcpKit
import HdWalletKit

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
    
    static func fromMnemonic(_ words: [String]) throws -> SimplePrincipal {
        let seed = HdWalletKit.Mnemonic.seed(mnemonic: words)!
        let xPrivKey = HDExtendedKeyVersion.xprv.rawValue
        let privateKey = try HDPrivateKey(seed: seed, xPrivKey: xPrivKey)
            .derived(at: 44, hardened: true)
            .derived(at: 223, hardened: true)
            .derived(at: 0, hardened: true)
            .derived(at: 0, hardened: false)
            .derived(at: 0, hardened: false)
        let publicKey = privateKey.publicKey(compressed: false)
        return try SimplePrincipal(privateKey: privateKey.raw, uncompressedPublicKey: publicKey.raw)
    }
}
