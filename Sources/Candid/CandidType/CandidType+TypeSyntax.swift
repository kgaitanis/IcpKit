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
            
        case .function(let signature):
            return "\(CandidPrimitiveType.function.syntax) \(signature.syntax)"
            
        case .service(let signature):
            guard !signature.methods.isEmpty else { return "service {}" }
            let methods = signature.methods.map { method in
                let functionSyntax: String
                switch method.functionSignature {
                case .concrete(let function):
                    functionSyntax = function.syntax
                case .reference(let name):
                    functionSyntax = name
                }
                return "\(method.name.candidLabelSyntax): \(functionSyntax);"
            }.joined(separator: " ")
            return "service { \(methods) }"
            
        case .named(let name): return name
        default: return primitiveType.syntax
        }
    }
}

private extension CandidFunctionSignature {
    // Shared by function types (with a "func" prefix) and inline service methods.
    var syntax: String {
        let inputs = arguments.map(\.syntax).joined(separator: ", ")
        let outputs = results.map(\.syntax).joined(separator: ", ")
        let modifiers = [
            annotations.query ? "query" : nil,
            annotations.oneWay ? "oneway" : nil,
            annotations.compositeQuery ? "composite_query" : nil,
        ].compactMap { $0 }
        return (["(\(inputs)) -> (\(outputs))"] + modifiers).joined(separator: " ")
    }
}

private extension CandidFunctionSignature.Parameter {
    var syntax: String {
        guard let name else { return type.syntax }
        return "\(name.candidLabelSyntax): \(type.syntax)"
    }
}

private extension String {
    static let candidKeywords: Set<String> = [
        "null", "opt", "vec", "record", "variant", "func", "service",
        "oneway", "query", "composite_query", "blob", "type", "import",
        "principal", "true", "false",
    ]

    var candidLabelSyntax: String {
        if !Self.candidKeywords.contains(self),
           range(of: #"\A[A-Za-z_][A-Za-z0-9_]*\z"#, options: .regularExpression) != nil {
            return self
        }
        let escaped = replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
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
