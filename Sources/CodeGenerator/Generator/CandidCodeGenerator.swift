//
//  CandidCodeGenerator.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation
import Candid

public enum CandidCodeGeneratorError: Error {
    case invalidServiceReference
    case invalidFunctionReference
}

public class CandidCodeGenerator {
    public struct Parameters {
        public let generateHeader: Bool
        
        public init(generateHeader: Bool) {
            self.generateHeader = generateHeader
        }
    }
    let parameters: Parameters
    
    public init() {
        self.parameters = Parameters(generateHeader: true)
    }
    
    public init(_ parameters: Parameters) {
        self.parameters = parameters
    }
    
    public func generateSwiftCode(for interface: CandidInterfaceDefinition, nameSpace: String) throws -> String {
        let context = try CodeGenerationContext(from: interface)
        let types = try context.namedTypes.map { try buildType($0, context.namedTypes)}
        
        let output = IndentedString()
        if parameters.generateHeader {
            output.addBlock(buildHeader(), newLine: true)
        }
        output.addLine("enum \(nameSpace) {")
        output.increaseIndent()
        output.addBlock(buildTypesBlock(types), newLine: true)
        if let service = context.service {
            let serviceBlock = try buildServiceBlock(service, context.namedTypes)
            output.addBlock(serviceBlock, newLine: true)
        }
        output.decreaseIndent()
        output.addLine("}")
        return output.output
    }
    
    public func generateSwiftCode(for value: CandidValue, valueName: String) throws -> String {
        let context = try CodeGenerationContext(from: value)
        let types = try context.namedTypes.map { try buildType($0, context.namedTypes)}
        
        let output = IndentedString()
        if parameters.generateHeader {
            output.addBlock(buildHeader(), newLine: true)
        }
        output.addBlock(buildTypesBlock(types))
        output.addBlock(buildValueBlock(value, valueName, context.candidValueSimplifiedType!))
        return output.output
    }
    
    private func buildValueBlock(_ value: CandidValue, _ valueName: String, _ simplifiedType: CandidType) -> IndentedString {
        let block = IndentedString.inline("let \(valueName): \(simplifiedType.swiftType()) = ")
        block.append(value.swiftValue)
        return block
    }
    
    private func buildServiceBlock(_ service: CodeGeneratorCandidService, _ namedTypes: [CandidNamedType]) throws -> IndentedString {
        switch service.type {
        case .reference(let referencedService):
            return IndentedString("typealias \(service.name) = \(referencedService)")
            
        case .concrete(let methods):
            let block = IndentedString()
            block.addSwiftDocumentation(service.originalDefinition)
            block.addLine("class \(service.name): ICPService {")
            block.increaseIndent()
            for method in methods {
                let methodBlock = try buildServiceMethod(method, namedTypes)
                block.addBlock(methodBlock, newLine: true)
            }
            block.decreaseIndent()
            block.addLine("}")
            return block
        }
    }
    
    private func getConcreteFunctionSignature(_ name: String, _ namedTypes: [CandidNamedType]) throws -> CandidFunctionSignature {
        guard let namedType = namedTypes[name] else {
            throw CandidCodeGeneratorError.invalidFunctionReference
        }
        switch namedType {
        case .named(let subRef): return try getConcreteFunctionSignature(subRef, namedTypes)
        case .function(let signature): return signature
        default: throw CandidCodeGeneratorError.invalidFunctionReference
        }
    }
    
    private func buildServiceMethod(_ method: CodeGeneratorCandidService.Method, _ namedTypes: [CandidNamedType]) throws -> IndentedString {
        let signature: CandidFunctionSignature
        let methodCaller: String
        switch method.signature {
        case .concrete(let concreteSignature):
            signature = concreteSignature
            methodCaller = signature.swiftType()
        case .reference(let referencedName):
            signature = try getConcreteFunctionSignature(referencedName, namedTypes)
            methodCaller = referencedName
        }
        let block = IndentedString()
        block.addSwiftDocumentation(method.originalDefinition)
        block.addLine(buildFunctionDefinition(method.name, signature))
        block.increaseIndent()
        block.addLine("let caller = \(methodCaller)(canister, \"\(method.name)\")")
        let args = signature.arguments.swiftStringForCallerInit
        let varName = signature.results.isEmpty ? "_" : "response"
        block.addLine("let \(varName) = try await caller.callMethod(\(args)client, sender: sender)")
        switch signature.results.count {
        case 0: break
        case 1: block.addLine("return response")
        default: block.addLine("return response.tuple")
        }
        block.decreaseIndent()
        block.addLine("}")
        return block
    }
    
    private func buildFunctionDefinition(_ name: String, _ signature: CandidFunctionSignature) -> String {
        let args = signature.arguments.isEmpty ? "" : "\(signature.arguments.swiftStringForArguments), "
        let results = signature.results.isEmpty ? "" : " -> \(signature.results.swiftStringForResults)"
        return "func \(name)(\(args)sender: ICPSigningPrincipal? = nil) async throws\(results) {"
    }
    
    private func buildTypesBlock(_ types: [GeneratedCode]) -> IndentedString {
        let typeAliases = types.filter { $0.type == .typeAlias }
        let namedTypes = types.filter { $0.type == .namedType }
        
        let block = IndentedString()
        typeAliases.sorted().forEach { block.addBlock($0.output, newLine: true) }
        if !typeAliases.isEmpty && !namedTypes.isEmpty { block.addLine() }
        namedTypes.sorted().forEach { block.addBlock($0.output, newLine: true) }
        return block
    }
    
    private func buildHeader() -> IndentedString {
        IndentedString(
            "//",
            "// This file was generated using IcpKit CandidCodeGenerator",
            "// For more information visit https://github.com/kgaitanis/IcpKit",
            "//",
            "",
            "import Foundation",
            "import IcpKit",
            "import BigInt"
        )
    }
        
    private func buildType(_ namedType: CandidNamedType, _ namedTypes: [CandidNamedType]) throws -> GeneratedCode {
        switch namedType.type.codeGenerationType {
        case .typealias(let candidType): return buildTypeAlias(namedType.name, candidType, namedType.originalDefinition)
        case .struct(let candidKeyedTypes): return buildStruct(namedType.name, candidKeyedTypes, namedType.originalDefinition)
        case .variant(let candidKeyedTypes): return buildVariant(namedType.name, candidKeyedTypes, namedType.originalDefinition, namedTypes)
        case .service(let signature): return try buildServiceType(namedType.name, signature, namedType.originalDefinition, namedTypes)
        }
    }
    
    private func buildServiceType(_ name: String, _ signature: CandidServiceSignature, _ originalDefinition: String?, _ namedTypes: [CandidNamedType]) throws -> GeneratedCode {
        let service = CodeGeneratorCandidService(
            name: name,
            type: .concrete(try signature.methods.map { .init(
                name: $0.name,
                originalDefinition: try CodeGeneratorCandidService.functionOriginalDefinition($0.name, serviceDefinition: originalDefinition),
                signature: $0.functionSignature) }),
            originalDefinition: originalDefinition
        )
        let serviceBlock = try buildServiceBlock(service, namedTypes)
        return GeneratedCode(name: name, output: serviceBlock, type: .namedType)
    }
        
    private func buildTypeAlias(_ name: String, _ type: CandidType, _ originalDefinition: String?) -> GeneratedCode {
        let output = IndentedString()
        output.addSwiftDocumentation(originalDefinition)
        output.addLine("typealias \(name) = \(type.swiftType())")
        return GeneratedCode(
            name: name,
            output: output,
            type: .typeAlias
        )
    }
    
    private func buildStruct(_ name: String, _ keyedTypes: CandidKeyedTypes, _ originalDefinition: String?) -> GeneratedCode {
        guard !keyedTypes.isTuple else {
            return GeneratedCode(
                name: name,
                output: IndentedString("typealias \(name) = \(CandidType.record(keyedTypes).swiftType())"),
                type: .typeAlias
            )
        }
        let block = IndentedString()
        block.addSwiftDocumentation(originalDefinition)
        block.addLine("struct \(name): Codable {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine("let \(keyedType.swiftString())")
        }
        if keyedTypes.hasUnnamedParameters {
            block.addLine()
            let initialiserArgs = keyedTypes.map { "\($0.key.swiftInitDefString): \($0.type.swiftType())" }.joined(separator: ", ")
            block.addLine("init(\(initialiserArgs)) {")
            block.increaseIndent()
            for arg in keyedTypes {
                block.addLine("self.\(arg.key.swiftString) = \(arg.key.swiftString)")
            }
            block.decreaseIndent()
            block.addLine("}")
            block.addLine()
            block.addBlock(buildCodingKeys(keyedTypes))
        }
        block.decreaseIndent()
        block.addLine("}")
        return GeneratedCode(name: name, output: block, type: .namedType)
    }
    
    private func buildVariant(_ name: String, _ keyedTypes: CandidKeyedTypes, _ originalDefinition: String?, _ namedTypes: [CandidNamedType]) -> GeneratedCode {
        let block = IndentedString()
        block.addSwiftDocumentation(originalDefinition)
        let indirect = keyedTypes.isIndirectEnum(name, namedTypes) ? "indirect " : ""
        block.addLine("\(indirect)enum \(name): Codable {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            block.addLine(buildVariantCase(keyedType))
        }
        block.addLine()
        block.addBlock(buildCodingKeys(keyedTypes))
        for keyedType in keyedTypes {
            guard case .record(let associatedValues) = keyedType.type,
                  associatedValues.hasNamedParameters,
                  let keyName = keyedType.key.stringValue else { continue }
            block.addBlock(buildCodingKeys(associatedValues, namePrefix: keyName.withFirstLetterCapital))
        }
        block.decreaseIndent()
        block.addLine("}")
        return GeneratedCode(name: name, output: block, type: .namedType)
    }
    
    private func buildVariantCase(_ keyedType: CandidKeyedType) -> String {
        switch keyedType.type {
        case .null, .empty, .reserved, .option(.null), .option(.empty):
            // no associated values `case noValue`
            return "case \(keyedType.key.swiftString)"
            
        case .record(let recordKeyedTypes):
            // multiple associated values `case multipleValues(String, name: Int)`
            let associatedValues = recordKeyedTypes.map {
                if let valueName = $0.key.stringValue {
                    return "\(valueName): \($0.type.swiftType())"
                }
                return $0.type.swiftType()
            }.joined(separator: ", ")
            return "case \(keyedType.key.swiftString)(\(associatedValues))"
            
        default:
            // single unnamed associatedValue `case singleValue(T)`
            return "case \(keyedType.key.swiftString)(\(keyedType.type.swiftType()))"
        }
    }
    
    private func buildCodingKeys(_ keyedTypes: CandidKeyedTypes, namePrefix: String = "") -> IndentedString {
        let block = IndentedString()
        let enumName = "\(namePrefix)CodingKeys"
        let enumInheritance = keyedTypes.hasUnnamedParameters ? "Int, CodingKey" : "String, CandidCodingKey"
        block.addLine("enum \(enumName): \(enumInheritance) {")
        block.increaseIndent()
        for keyedType in keyedTypes {
            if keyedTypes.isTuple || !keyedTypes.hasUnnamedParameters {
                block.addLine("case \(keyedType.key.swiftString)")
            } else {
                block.addLine("case \(keyedType.key.swiftString) = \(keyedType.key.intValue)")
            }
        }
        block.decreaseIndent()
        block.addLine("}")
        return block
    }
}



private struct GeneratedCode: Comparable {
    let name: String
    let output: IndentedString
    let type: GeneratedCodeType
    
    static func < (lhs: GeneratedCode, rhs: GeneratedCode) -> Bool { lhs.name < rhs.name }
    static func == (lhs: GeneratedCode, rhs: GeneratedCode) -> Bool { lhs.name == rhs.name }
}

private enum GeneratedCodeType {
    case typeAlias
    case namedType
}

private enum CodeGenerationCandidType {
    case `typealias`(CandidType)
    case `struct`(CandidKeyedTypes)
    case variant(CandidKeyedTypes)
    case service(CandidServiceSignature)
}

fileprivate extension CandidType {
    var codeGenerationType: CodeGenerationCandidType {
        switch self {
        case .variant(let keyedTypes): return .variant(keyedTypes)
        case .record(let keyedTypes): return .struct(keyedTypes)
        case .service(let signature): return .service(signature)
        default: return .typealias(self)
        }
    }
    
    func swiftType() -> String {
        switch self {
        case .null, .reserved, .empty: return "CandidTuple0"
        case .bool: return "Bool"
        case .natural: return "BigUInt"
        case .integer: return "BigInt"
        case .natural8: return "UInt8"
        case .natural16: return "UInt16"
        case .natural32: return "UInt32"
        case .natural64: return "UInt64"
        case .integer8: return "Int8"
        case .integer16: return "Int16"
        case .integer32: return "Int32"
        case .integer64: return "Int64"
        case .float32: return "Float"
        case .float64: return "Double"
        case .text: return "String"
        case .blob: return "Data"
        case .option(let candidType): return "\(candidType.swiftType())?"
        case .vector(let candidType):
            return "[\(candidType.swiftType())]"
        case .record(let keyedTypes):
            guard keyedTypes.isTuple else {
                fatalError("all non-tuple records should be named by now")
            }
            guard keyedTypes.count > 0 else {
                return "CandidTuple0"
            }
            return "CandidTuple\(keyedTypes.count)<\(keyedTypes.map { $0.type.swiftType() }.joined(separator: ", "))>"
        case .variant:
            fatalError("all variants should be named by now")
        case .function(let signature): return signature.swiftType()
        case .service: return "CandidServiceSignature"
        case .principal: return "ICPPrincipal"
        case .named(let name): return name
        }
    }
}

private extension CandidFunctionSignature {
    func swiftType() -> String {
        switch (arguments.isEmpty, results.isEmpty, annotations.query) {
        case (true, true, false): return "ICPCallNoArgsNoResult"
        case (true, false, false): return "ICPCallNoArgs<\(results.swiftStringForFunctionType)>"
        case (false, true, false): return "ICPCallNoResult<\(arguments.swiftStringForFunctionType)>"
        case (false, false, false): return "ICPCall<\(arguments.swiftStringForFunctionType), \(results.swiftStringForFunctionType)>"
        case (true, true, true): return "ICPQueryNoArgsNoResult"
        case (true, false, true): return "ICPQueryNoArgs<\(results.swiftStringForFunctionType)>"
        case (false, true, true): return "ICPQueryNoResult<\(arguments.swiftStringForFunctionType)>"
        case (false, false, true): return "ICPQuery<\(arguments.swiftStringForFunctionType), \(results.swiftStringForFunctionType)>"
        }
    }
}

private extension IndentedString {
    func addSwiftDocumentation(_ originalString: String?) {
        guard let string = originalString else { return }
        for line in string.split(separator: "\n") {
            addLine("/// \(line)")
        }
    }
}

private extension CandidKeyedTypes {
    var hasUnnamedParameters: Bool { contains { $0.key.isUnnamed }}
    var hasNamedParameters: Bool { contains { $0.key.hasString }}
}

private extension CandidKeyedType {
    func swiftString() -> String { "\(key.swiftString): \(type.swiftType())" }
}

private extension CandidKey {
    var isUnnamed: Bool { stringValue == nil }
    var swiftString: String {
        if let string = stringValue {
            return sanitize(string)
        } else {
            return "_\(intValue)"
        }
    }
    /// used for init definition eg. MyType{ init(_ _0: Int, a: String) }
    var swiftInitDefString: String {
        if hasString {
            return swiftString
        } else {
            return "_ \(swiftString)"
        }
    }
    /// used for value init eg. MyType(0, a: "string")
    var swiftInitString: String {
        if hasString {
            return "\(swiftString): "
        } else {
            return ""
        }
    }
    
    private func sanitize(_ string: String) -> String {
        if Self.swiftReservedKeywords.contains(string) {
            return "`\(string)`"
        }
        return string
    }
    
    private static let swiftReservedKeywords = ["extension", "private", "public", "internal", "operator", "var", "let", "func", "default", "if", "while"]
}

private extension CandidFunctionSignature.Parameter {
    var swiftStringForFunctionArgument: String {
        if let name = name {
            return "\(name): \(type.swiftType())"
        }
        let string = "_ args: \(type.swiftType())"
        return string
    }
    
    func swiftStringForFunctionMultipleResult() -> String {
        if let name = name {
            return "\(name): \(type.swiftType())"
        }
        return type.swiftType()
    }
    
    func swiftStringForArgument(_ count: inout Int) -> String {
        if let name = name {
            return "\(name): \(type.swiftType())"
        }
        let string = "_ arg\(count): \(type.swiftType())"
        count += 1
        return string
    }
}

private extension Array where Element == CandidFunctionSignature.Parameter {
    var swiftStringForResults: String {
        switch count {
        case 0: return ""
        case 1: return first!.type.swiftType()
        default:
            return "(\(map { $0.swiftStringForFunctionMultipleResult() }.joined(separator: ", ")))"
        }
    }
    
    var swiftStringForArguments: String {
        if isEmpty { return "" }
        var unnamedCount = 0
        return map { $0.swiftStringForArgument(&unnamedCount) }.joined(separator: ", ")
    }
    
    var swiftStringForFunctionType: String {
        switch count {
        case 0: return ""
        case 1: return first!.type.swiftType()
        default:
            let types = map { $0.type.swiftType() }.joined(separator: ", ")
            return "ICPFunctionArgs\(count)<\(types)>"
        }
    }
    
    var swiftStringForCallerInit: String {
        switch count {
        case 0: return ""
        case 1: return "\(first!.name ?? "arg0"), "
        default:
            var count = 0
            let args = map {
                if let name = $0.name { return name }
                let arg = "arg\(count)"
                count += 1
                return arg
            }.joined(separator: ", ")
            return ".init(\(args)), "
        }
    }
}

private extension CandidKeyedTypes {
    func isIndirectEnum(_ name: String, _ namedTypes: [CandidNamedType]) -> Bool {
        contains { $0.type.references(name, namedTypes) }
    }
}

private extension CandidType {
    func references(_ name: String, _ namedTypes: [CandidNamedType]) -> Bool {
        switch self {
        case .option(let containedType): return containedType.references(name, namedTypes)
        case .named(let referencedName): 
            if referencedName == name { return true }
            return namedTypes[referencedName]?.references(name, namedTypes) ?? false
            
        default: return false
        }
    }
}

private extension CandidValue {
    var swiftValue: IndentedString {
        switch self {
        case .null, .reserved, .empty: return IndentedString.inline("nil")
        case .bool(let bool): return IndentedString.inline("\(bool)")
        case .natural(let bigUInt): return IndentedString.inline("\(bigUInt)")
        case .integer(let bigInt): return IndentedString.inline("\(bigInt)")
        case .natural8(let uInt8): return IndentedString.inline("\(uInt8)")
        case .natural16(let uInt16): return IndentedString.inline("\(uInt16)")
        case .natural32(let uInt32): return IndentedString.inline("\(uInt32)")
        case .natural64(let uInt64): return IndentedString.inline("\(uInt64)")
        case .integer8(let int8): return IndentedString.inline("\(int8)")
        case .integer16(let int16): return IndentedString.inline("\(int16)")
        case .integer32(let int32): return IndentedString.inline("\(int32)")
        case .integer64(let int64): return IndentedString.inline("\(int64)")
        case .float32(let float): return IndentedString.inline("\(float)")
        case .float64(let double): return IndentedString.inline("\(double)")
        case .text(let string): return IndentedString.inline("\"\(string)\"")
        case .blob(let data): return IndentedString.inline("Data.fromHex(\"\(data.hex)\")!")
            
        case .option(let option):
            if let value = option.value { return value.swiftValue }
            else { return IndentedString.inline("nil") }
            
        case .vector(let vector):
            if vector.values.isEmpty { return IndentedString.inline("[]") }
            let block = IndentedString()
            block.addLine("[")
            block.increaseIndent()
            for value in vector.values {
                block.append(value.swiftValue)
                block.append(",\n")
            }
            block.decreaseIndent()
            block.addLine("]")
            return block
            
        case .record(let record):
            if record.candidSortedItems.isEmpty { return IndentedString.inline(".init()") }
            
            let block = IndentedString(".init(")
            block.increaseIndent()
            let initValues = record.candidSortedItems.map { "\($0.key.swiftInitString)\($0.value.swiftValue.output)" }.joined(separator: ",\n")
            block.append(initValues)
            block.decreaseIndent()
            block.addLine()
            block.append(")")
            return block
            
        case .variant(let variant):
            switch variant.value {
            case .record(let record):
                // named and/or multiple associated values
                let associatedValues = record.candidSortedItems.map { "\($0.key.swiftInitString)\($0.value.swiftValue.output)" }.joined(separator: ", ")
                
                return IndentedString.inline(".\(variant.key.swiftString)(\(associatedValues))")
            case .null:
                return IndentedString.inline(".\(variant.key.swiftString)")
            default:
                // single unnamed associated value
                return IndentedString.inline(".\(variant.key.swiftString)(\(variant.value.swiftValue.output))")
            }
            
        case .principal(let candidPrincipal):
            guard let principal = candidPrincipal else { return IndentedString.inline("nil") }
            return IndentedString.inline(principal.swiftValueInit)
        
        case .function(let candidFunction):
            guard let method = candidFunction.method else {
                return IndentedString.inline("nil")
            }
            return IndentedString.inline(".init(\(method.principal.swiftValueInit), \"\(method.name)\")")
            
        case .service(let candidService):
            guard let principal = candidService.principal else {
                return IndentedString.inline("nil")
            }
            return IndentedString.inline(".init(\(principal.swiftValueInit))")
        }
    }
}

private extension CandidPrincipal {
    var swiftValueInit: String { "\"\(string)\"" }
}

private extension String {
    var withFirstLetterCapital: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + self.dropFirst()
    }
}
