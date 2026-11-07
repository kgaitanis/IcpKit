import Foundation
import IcpKit

/// A token registry with balance and transaction access.
public protocol TokenService: Sendable {
    func tokenStandard(for canister: ICPPrincipal) async throws -> ICPTokenStandard?
    func `actor`(for standard: ICPTokenStandard, _ canister: ICPPrincipal) -> ICPTokenActor?
    func `actor`(for canister: ICPPrincipal) async throws -> ICPTokenActor?
    func `actor`(for token: ICPToken) -> ICPTokenActor?
    /// Returns a cached token without fetching the registry.
    func token(for canister: ICPPrincipal) -> ICPToken?
    func allTokens() async throws -> [ICPToken]
    func balance(of user: ICPAccount) async throws -> [ICPTokenBalance]
    func transactions(of user: ICPAccount, for token: ICPToken) async throws -> [ICPTokenTransaction]
    func transactions(of user: ICPAccount, for tokenCanister: ICPPrincipal) async throws -> [ICPTokenTransaction]
    func explorerUrl(tokenCanister: ICPPrincipal, transactionIndex: String) async throws -> URL?
}

public extension TokenService {
    func tokenStandard(for canister: ICPPrincipal) async throws -> ICPTokenStandard? {
        try await allTokens().first(where: { $0.canister == canister })?.standard
    }

    func `actor`(for canister: ICPPrincipal) async throws -> ICPTokenActor? {
        guard let standard = try await tokenStandard(for: canister) else { return nil }
        return actor(for: standard, canister)
    }

    func `actor`(for token: ICPToken) -> ICPTokenActor? {
        actor(for: token.standard, token.canister)
    }

    func balance(of user: ICPAccount) async throws -> [ICPTokenBalance] {
        let tokens = try await allTokens()
        return await tokens.compactMapParallel { token in
            guard let actor = self.actor(for: token.standard, token.canister),
                  let balance = try? await actor.balance(of: user),
                  balance > .zero else {
                return ICPTokenBalance?.none
            }
            return ICPTokenBalance(token: token, balance: balance)
        }
    }

    func transactions(of user: ICPAccount, for token: ICPToken) async throws -> [ICPTokenTransaction] {
        try await transactions(of: user, for: token.canister)
    }
}
