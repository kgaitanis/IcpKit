//
//  IcpViewModel.swift
//  AppIcp
//
//  Created by Konstantinos Gaitanis on 20.11.23.
//

import Foundation
import IcpKit

class IcpViewModel: ObservableObject {
    @Published var balance: UInt64? = nil
    @Published var isBusy = false
    @Published var transactionBlock: UInt64?
    
    private let client = ICPRequestClient()
    private let signingPrincipal: ICPSigningPrincipal
    let account: ICPAccount
    
    init() throws {
        signingPrincipal = try SimplePrincipal.fromMnemonic(AccountKeys.mnemonic)
        account = ICPAccount.mainAccount(of: signingPrincipal.principal)
    }
    
    @MainActor
    func queryBalance() async throws {
        isBusy = true
        defer { isBusy = false }
        balance = try await ICPLedgerCanister.accountBalance(of: account, client)
    }
    
    @MainActor
    func send() async throws {
        isBusy = true
        defer { isBusy = false }
        transactionBlock = try await ICPLedgerCanister.transfer(
            from: account,
            to: account.address,
            amount: 10000,
            signingPrincipal: signingPrincipal,
            client
        )
    }
}

