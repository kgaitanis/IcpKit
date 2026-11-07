//
//  DABTokenService.swift
//
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import Foundation
import IcpKit
import BigInt

public enum DABTokenServiceError: Error {
    case tokenNotFound
}

extension DABTokens.Service: @unchecked Sendable {}

public class DABTokenService: TokenService, @unchecked Sendable {
    private let client: ICPRequestClient
    private let service: DABTokens.Service
    private let transactionProvider: ICPTransactionProvider
    
    private var cachedTokens: [ICPToken]?
    
    public init(_ client: ICPRequestClient = ICPRequestClient()) {
        self.client = client
        transactionProvider = ICPTransactionProvider(client)
        service = DABTokens.Service(DABService.tokenRegistry, client: client)
    }
    
    public func `actor`(for standard: ICPTokenStandard, _ canister: ICPPrincipal) -> ICPTokenActor? {
        ICPTokenActorFactory.actor(for: standard, canister, client)
    }
    
    public func token(for canister: ICPPrincipal) -> ICPToken? {
        cachedTokens?.first { $0.canister == canister }
    }
    
    public func allTokens() async throws -> [ICPToken] {
        if let cachedTokens = cachedTokens { return cachedTokens }
        cachedTokens = try await withThrowingTaskGroup(of: [ICPToken].self) { group in
            group.addTask { try await self.service.get_all().map(ICPToken.init) }
            group.addTask { [try await self.buildIcpToken()] }
            var tokens: [ICPToken] = []
            for try await tokenList in group {
                tokens.append(contentsOf: tokenList)
            }
            return tokens
        }
        return cachedTokens!
    }
    
    public func transactions(of user: ICPAccount, for tokenCanister: ICPPrincipal) async throws -> [ICPTokenTransaction] {
        guard let token = token(for: tokenCanister) else {
            throw DABTokenServiceError.tokenNotFound
        }
        return try await transactionProvider.transactions(of: user, token: token)
    }
    
    public func explorerUrl(tokenCanister: ICPPrincipal, transactionIndex: String) async throws -> URL? {
        try await transactionProvider.explorerUrl(tokenCanister: tokenCanister, transactionIndex: transactionIndex)
    }
}

private extension DABTokenService {
    func buildIcpToken() async throws -> ICPToken {
        let actor = ICPTokenActorFactory.actor(for: .icp, ICPSystemCanisters.ledger, client)!
        let metadata = try await actor.metaData()
        return ICPToken(standard: .icp, canister: ICPSystemCanisters.ledger, metadata: metadata)
    }
}

private extension ICPToken {
    init(_ dabToken: DABTokens.token) throws {
        guard let standard = ICPTokenStandard(try dabToken.details["standard"]?.textValue),
              let decimals = try dabToken.details["decimals"]?.u64Value,
              let symbol = try dabToken.details["symbol"]?.textValue,
              let verified = try dabToken.details["verified"]?.boolValue else {
            throw DABTokens.detail_value.TypeError.invalidType
        }
        self.standard = standard
        self.canister = dabToken.principal_id
        self.name = dabToken.name
        self.decimals = UInt(decimals)
        self.symbol = symbol
        self.verified = verified
        self.logo = URL(string: dabToken.thumbnail)
    }
}

private typealias DABTokenDetail = CandidTuple2<String, DABTokens.detail_value>
private extension [DABTokenDetail] {
    subscript (_ key: String) -> DABTokens.detail_value? {
        first(where: { $0._0 == key})?._1
    }
}

private extension DABTokens.detail_value {
    enum TypeError: Error { case invalidType }
    var textValue: String {
        get throws {
            guard case .Text(let text) = self else {
                throw TypeError.invalidType
            }
            return text
        }
    }
    
    var u64Value: UInt64 {
        get throws {
            guard case .U64(let u64) = self else {
                throw TypeError.invalidType
            }
            return u64
        }
    }
    
    var boolValue: Bool {
        get throws {
            if case .True = self { return true }
            else if case .False = self { return false }
            throw TypeError.invalidType
        }
    }
}

private extension ICPTokenStandard {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(rawValue: string)
    }
}
