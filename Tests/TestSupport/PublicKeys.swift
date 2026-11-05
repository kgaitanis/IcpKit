//
//  PublicKeys.swift
//
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation
import IcpKit

enum PublicKeys {
    static let devWallet1 = Data.fromHex("046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")!
}

let devWallet1 = try! SimplePrincipal(privateKey: Data(), uncompressedPublicKey: PublicKeys.devWallet1)
let devWallet1Account = ICPAccount.mainAccount(of: devWallet1.principal)
