//
//  CandidServiceProtocol.swift
//
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation

public protocol CandidServiceProtocol: Codable {
    var principal: CandidPrincipal { get }
    
    init(_ principal: CandidPrincipal)
}

public extension CandidServiceProtocol {
    init(_ principal: String) throws {
        self.init(try CandidPrincipal(principal))
    }
}
