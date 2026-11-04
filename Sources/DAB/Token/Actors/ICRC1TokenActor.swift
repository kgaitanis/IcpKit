//
//  ICRC1TokenActor.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import IcpKit
import BigInt

enum ICRC1TokenError: Error {
    case invalidMetadata
    case approveNotSupported
}

class ICRC1TokenActor: ICPTokenActor {
    let standard: ICPTokenStandard = .icrc1
    private let service: ICRC1.Service
    private lazy var service2: ICRC2.Service = { ICRC2.Service(service.canister, client: service.client) }()
    
    required init(_ canister: IcpKit.ICPPrincipal, _ client: IcpKit.ICPRequestClient) {
        service = ICRC1.Service(canister, client: client)
    }
    
    func balance(of user: ICPAccount) async throws -> BigUInt {
        let balance = try await service.icrc1_balance_of(.init(user))
        return balance
    }
    
    func fee() async throws -> BigUInt {
        try await service.icrc1_fee()
    }
    
    func metaData() async throws -> ICPTokenMetadata {
        let metadata = try await service.icrc1_metadata()
        let totalSupply = try await service.icrc1_total_supply()
        return try ICPTokenMetadata(totalSupply, metadata)
    }
        
    func transfer(_ args: ICPTokenTransferArgs) async throws -> ICPTokenTransferResponse {
        let response = try await service.icrc1_transfer(.init(args), sender: args.sender).get()
        return .height(response)
    }
    
    func approve(_ args: ICPTokenApproveArgs) async throws {
        let supportedStandards = try await service.icrc1_supported_standards()
        guard supportedStandards.map({ $0.name }).contains("ICRC-2") else {
            throw ICRC1TokenError.approveNotSupported
        }
        // see https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-1/README.md#extensions-
        let fee = try await service.icrc1_fee()
        let _ = try await service2.icrc2_approve(ICRC2.ApproveArgs(fee, args), sender: args.sender).get()
    }
}

private extension ICRC2.ApproveArgs {
    init(_ fee: BigUInt, _ args: ICPTokenApproveArgs) {
        self.fee = fee
        memo = args.memo
        from_subaccount = nil
        created_at_time = Date().nanoSecondsSince1970
        amount = args.amount
        expected_allowance = nil
        expires_at = Date().addingTimeInterval(1 * 24 * 60 * 60).nanoSecondsSince1970    // + 1 day
        spender = .init(owner: args.spender, subaccount: nil)
    }
}

private extension ICRC2.ApproveResult {
    func get() throws -> BigUInt {
        switch self {
        case .Ok(let allowance): return allowance
        case .Err(let error): throw error
        }
    }
}

extension ICRC2.ApproveError: Error, @unchecked Sendable {}


private extension ICRC1.TransferArgs {
    init(_ args: ICPTokenTransferArgs) {
        to = .init(owner: args.to.principal, subaccount: args.to.subAccountId)
        fee = args.fee
        memo = args.memo
        from_subaccount = args.from.subAccountId
        created_at_time = args.createdAtTime?.nanoSecondsSince1970
        amount = args.amount
    }
}

private extension ICPTokenMetadata {
    init(_ totalSupply: BigUInt, _ metadata: [ICRC1.MetadataField]) throws {
        guard let name = try metadata["icrc1:name"]?.textValue,
              let symbol = try metadata["icrc1:symbol"]?.textValue,
              let decimals = try metadata["icrc1:decimals"]?.natValue,
              let fee = try metadata["icrc1:fee"]?.natValue else {
            throw ICRC1TokenError.invalidMetadata
        }
        let logo: URL?
        if let logoString = try metadata["icrc1:logo"]?.textValue {
            guard let logoUrl = URL(string: logoString) else {
                throw ICRC1TokenError.invalidMetadata
            }
            logo = logoUrl
        } else {
            logo = nil
        }
        
        self.name = name
        self.symbol = symbol
        self.decimals = Int(decimals)
        self.totalSupply = totalSupply
        self.logo = logo
        self.fee = fee
    }
}

private extension ICRC1.TransferResult {
    func get() throws -> BigUInt {
        switch self {
        case .Ok(let bigUInt): return bigUInt
        case .Err(let error): throw error
        }
    }
}

extension ICRC1.TransferError: Error, @unchecked Sendable {}

private extension [ICRC1.MetadataField] {
    subscript (_ key: String) -> ICRC1.Value? {
        first { $0._0 == key }?._1
    }
}

private extension ICRC1.Value {
    enum TypeError: Error { case invalidType }
    var textValue: String { get throws {
        guard case .Text(let string) = self else {
            throw TypeError.invalidType
        }
        return string
    }}
    
    var natValue: BigUInt { get throws {
        guard case .Nat(let bigUInt) = self else {
            throw TypeError.invalidType
        }
        return bigUInt
    }}
}

private extension ICRC1.Account {
    init(_ account: ICPAccount) {
        owner = account.principal
        subaccount = account.subAccountId
    }
}
