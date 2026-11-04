//
//  CandidFunctionProtocol.swift
//  
//
//  Created by Konstantinos Gaitanis on 02.08.24.
//

import Foundation

public protocol CandidFunctionProtocol: Codable {
    var canister: CandidPrincipal { get }
    var methodName: String { get }
    var isQuery: Bool { get }
    
    init(_ canister: CandidPrincipal, _ methodName: String)
}

public extension CandidFunctionProtocol {
    init(_ canister: String, _ methodName: String) throws {
        self.init(try CandidPrincipal(canister), methodName)
    }
}

public protocol CandidFunctionSignatureProtocol {
    static var signature: CandidFunctionSignature { get }
}
