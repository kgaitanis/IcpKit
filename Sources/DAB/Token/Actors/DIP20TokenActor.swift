//
//  DIP20TokenActor.swift
//
//
//  Created by Konstantinos Gaitanis on 06.09.24.
//

import Foundation
import IcpKit
import BigInt

class DIP20TokenActor: ICPTokenActor {
    let standard: ICPTokenStandard = .dip20
    let service: DIP20.Service
    
    required init(_ canister: ICPPrincipal, _ client: ICPRequestClient) {
        service = DIP20.Service(canister, client: client)
    }
    
    func fee() async throws -> BigUInt {
        try await metaData().fee
    }
    
    func metaData() async throws -> ICPTokenMetadata {
        let metadata = try await service.getMetadata()
        return ICPTokenMetadata(metadata)
    }
    
    func balance(of user: ICPAccount) async throws -> BigUInt {
        let balance = try await service.balanceOf(who: user.principal)
        return balance
    }
    
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse {
        let blockIndex = try await service.transfer(to: args.to.principal, value: args.amount, sender: args.sender).get()
        return .height(blockIndex)
    }
    
    func approve(_ args: ICPTokenApproveArgs) async throws {
        let _ = try await service.approve(spender: args.spender, value: args.amount, sender: args.sender).get()
    }
}

private extension ICPTokenMetadata {
    init(_ metadata: DIP20.Metadata) {
        name = metadata.name
        symbol = metadata.symbol
        decimals = Int(metadata.decimals)
        totalSupply = metadata.totalSupply
        logo = URL(string: metadata.logo)
        fee = metadata.fee
    }
}

private extension DIP20.TxReceipt {
    func get() throws -> BigUInt {
        switch self {
        case .Ok(let blockIndex): return blockIndex
        case .Err(let error): throw error
        }
    }
}

extension DIP20.TxError: Error, @unchecked Sendable {}
