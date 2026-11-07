//
//  AppController.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import Foundation
import DAB
import IcpKit
import BigInt

class AppController: ObservableObject {
    @Published var collections: [ICPNftCollection]?
    @Published var tokens: [ICPToken]?
    @Published var myNFTs: [ICPNftDetails]? = []
    @Published var myTokens: [ICPTokenBalance] = []
    
    let nftService = DABNftService()
    let tokenService = DABTokenService()
    
    init() { refresh() }
    
    func refresh() {
        refreshCollections()
        refreshTokens()
    }
    
    open func refreshCollections() {
        self.collections = nil
        Task {
            let collections = try await nftService.allCollections()
            DispatchQueue.main.async { self.collections = collections }
        }
    }
    
    open func refreshTokens() {
        self.tokens = nil
        Task {
            let tokens = try await tokenService.allTokens()
            DispatchQueue.main.async { self.tokens = tokens }
        }
    }
    
    func fetchNfts(_ principalString: String) {
        myTokens = []
        guard let principal = try? ICPPrincipal(principalString) else {
            myNFTs = []
            return
        }
        myNFTs = nil
        Task {
            try await withThrowingTaskGroup(of: Balance.self) { group in
                group.addTask { .nfts(try await self.nftService.holdings(principal).flatMap { $0.nfts }) }
                group.addTask { .tokens(try await self.tokenService.balance(of: .mainAccount(of: principal))) }

                for try await result in group {
                    switch result {
                    case .nfts(let nfts): DispatchQueue.main.async { self.myNFTs = nfts }
                    case .tokens(let tokens): DispatchQueue.main.async { self.myTokens = tokens }
                    }
                }
            }
        }
    }
}

private enum Balance {
    case nfts([ICPNftDetails])
    case tokens([ICPTokenBalance])
}
