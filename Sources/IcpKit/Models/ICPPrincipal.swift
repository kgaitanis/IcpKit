//
//  ICPPrincipal.swift
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import Foundation
import Candid

public typealias ICPPrincipal = CandidPrincipal

public extension ICPPrincipal {
    /// Self-authenticating principal: SHA-224(DER public key) followed by 0x02.
    init(publicKey: ICPPublicKey) throws {
        self.init(ICPCryptography.sha224(try publicKey.derRepresentation) + Data([0x02]))
    }
}
