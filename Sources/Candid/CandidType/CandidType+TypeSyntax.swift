//
//  CandidType+TypeSyntax.swift
//  
//
//  Created by Konstantinos Gaitanis on 26.06.24.
//

import Foundation

public extension CandidType {
    var syntax: String {
        switch self {
        case .vector(let containedType), .option(let containedType):
            return "\(primitiveType.syntax) \(containedType.syntax)"
            
        case .record(let items), .variant(let items):
            let itemString = items.map { "\($0.key.stringValue ?? String($0.key.intValue)): \($0.type.syntax)" }.joined(separator: "; ")
            return "\(primitiveType.syntax) { \(itemString)}"
            
        case .function(_):
            return "\(CandidPrimitiveType.function.syntax) () -> ()"
            
        case .service(_):
            return "\(CandidPrimitiveType.service.syntax) {}"
            
        case .named(let name): return name
        default: return primitiveType.syntax
        }
    }
}

public extension CandidPrimitiveType {
    var syntax: String {
        switch self {
        case .null: return "null"
        case .bool: return "bool"
        case .natural: return "nat"
        case .integer: return "int"
        case .natural8: return "nat8"
        case .natural16: return "nat16"
        case .natural32: return "nat32"
        case .natural64: return "nat64"
        case .integer8: return "int8"
        case .integer16: return "int16"
        case .integer32: return "int32"
        case .integer64: return "int64"
        case .float32: return "float32"
        case .float64: return "float64"
        case .text: return "text"
        case .reserved: return "reserved"
        case .empty: return "empty"
        case .option: return "opt"
        case .vector: return "vec"
        case .record: return "record"
        case .variant: return "variant"
        case .function: return "func"
        case .principal: return "principal"
        case .service: return "service"
        }
    }
}
