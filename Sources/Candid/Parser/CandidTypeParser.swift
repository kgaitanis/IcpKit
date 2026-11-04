//
//  CandidParser.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import Foundation

/// https://internetcomputer.org/docs/current/references/candid-ref#supported-types
/// https://github.com/dfinity/candid/blob/master/spec/Candid.md
/// An interface description consists of a sequence of imports and type definitions, possibly followed by a service declaration. A service declaration names and specifies a service actor by specifying an actor type. The actor type may also be given by referring to the name of a type definition for an actor reference type.
/// The optional name given to the service in an interface description is immaterial; it only serves as documentation.
///
/// The Grammar used: https://github.com/dfinity/candid/blob/master/spec/Candid.md#core-grammar
/// <prog>  ::= <def>;* <actor>?
/// <def>   ::= type <id> = <datatype> | import service? <text>
/// <actor> ::= service <id>? : (<tuptype> ->)? (<actortype> | <id>) ;?
///
/// <actortype> ::= { <methtype>;* }
/// <methtype>  ::= <name> : (<functype> | <id>)
/// <functype>  ::= <tuptype> -> <tuptype> <funcann>*
/// <funcann>   ::= oneway | query | composite_query
/// <tuptype>   ::= ( <argtype>,* )
/// <argtype>   ::= <datatype>
/// <fieldtype> ::= <nat> : <datatype>
/// <datatype>  ::= <id> | <primtype> | <comptype>
/// <comptype>  ::= <constype> | <reftype>
///
/// <primtype>  ::=
/// | <numtype>
/// | bool
/// | text
/// | null
/// | reserved
/// | empty
/// | principal
///
/// <numtype>  ::=
/// | nat | nat8 | nat16 | nat32 | nat64
/// | int | int8 | int16 | int32 | int64
/// | float32 | float64
///
/// <constype>  ::=
/// | opt <datatype>
/// | vec <datatype>
/// | record { <fieldtype>;* }
/// | variant { <fieldtype>;* }
///
/// <reftype>  ::=
/// | func <functype>
/// | service <actortype>
///
/// <letter> ::= A..Z | a..z
/// <digit>  ::= 0..9
/// <id>     ::= (<letter> | _)(<letter> | <digit> | _)*
///
/// <hex>    ::= <digit> | A..F | a..f
/// <num>    ::= <digit>(_? <digit>)*
/// <hexnum> ::= <hex>(_? <hex>)*
/// <nat>    ::= <num> | 0x<hexnum>
///
/// <text>   ::= " <char>* "
/// <char>   ::=
/// | <utf8>
/// | \ <hex> <hex>
/// | \ <escape>
/// | \u{ <hexnum> }
/// <escape>  ::= n | r | t | \ | " | '
/// <utf8>    ::= <ascii> | <utf8enc>
/// <ascii>   ::= '\20'..'\7e' except " or \
/// <utf8enc> ::=
/// | '\c2'..'\df' <utf8cont>
/// | '\e0' '\a0'..'\bf' <utf8cont>
/// | '\ed' '\80'..'\9f' <utf8cont>
/// | '\e1'..'\ec' <utf8cont> <utf8cont>
/// | '\ee'..'\xef' <utf8cont> <utf8cont>
/// | '\f0' '\90'..'\bf' <utf8cont> <utf8cont>
/// | '\f4' '\80'..'\8f' <utf8cont> <utf8cont>
/// | '\f1'..'\f3' <utf8cont> <utf8cont> <utf8cont>
/// <utf8cont> ::= '\80'..'\bf'
///
/// <name> ::= <id> | <text>
class CandidTypeParser: CandidParserBase {
    func parseSingleType(_ input: String) throws -> CandidType {
        let stream = try CandidParserStream(string: input)
        return try parseCandidType(stream)
    }
    
    func parseInterfaceDescription(_ provider: CandidInterfaceDefinitionProvider) async throws -> CandidInterfaceDefinition {
        let mainContent = try await provider.readMain()
        let stream = try CandidParserStream(string: mainContent)
        return try await parseInterfaceDescription(provider, stream)
    }
}

private extension CandidTypeParser {
    func parseInterfaceDescription(_ provider: CandidInterfaceDefinitionProvider, _ stream: CandidParserStream) async throws -> CandidInterfaceDefinition {
        let context = ParsingContext()
        while try stream.hasNext && stream.peekNext() != .word(CandidPrimitiveType.service.syntax) {
            if try stream.takeIfNext(is: .word("type")) {
                let namedType = try parseNamedType(stream)
                try context.add(namedType)
                
            } else if try stream.takeIfNext(is: .word("import")) {
                try await parseImportStatement(stream, context, provider)
                
            } else {
                throw CandidParserError.expecting("'type', 'import' or 'service'", butGot: try stream.peekNext().syntax)
            }
        }
        if try stream.takeIfNext(is: .word(CandidPrimitiveType.service.syntax)) {
            let service = try parseServiceDefinition(stream)
            try context.setService(service)
        }
        return CandidInterfaceDefinition(context.namedTypes, service: context.service)
    }
    
    /// import service? <text>
    func parseImportStatement(_ stream: CandidParserStream, _ context: ParsingContext, _ provider: CandidInterfaceDefinitionProvider) async throws {
        let importService = try stream.takeIfNext(is: .word("service"))
        let fileName = try stream.expectNextTextOrWord()
        try stream.expectNext(.semicolon)
        stream.setMarker()
        
        let fileContents = try await provider.read(contentsOf: fileName)
        let importedStream = try CandidParserStream(string: fileContents)
        let interface = try await parseInterfaceDescription(provider, importedStream)
        for namedType in interface.namedTypes {
            try context.add(namedType)
        }
        if importService, let service = interface.service {
            try context.setService(service)
        }
    }
    
    /// <def>   ::= type <id> = <datatype> | import service? <text>
    func parseNamedType(_ stream: CandidParserStream) throws -> CandidNamedType {
        let name = try stream.expectNextId()
        try stream.expectNext(.equals)
        let type = try parseCandidType(stream)
        try stream.expectNext(.semicolon)
        let originalDefinition = stream.originalStringSinceLastMarker()
        return CandidNamedType(name: name, type: type, originalDefinition: originalDefinition)
    }
    
    func parseCandidType(_ stream: CandidParserStream) throws -> CandidType {
        let type = try stream.expectNextId()
        switch type {
        case CandidPrimitiveType.null.syntax: return .null
        case CandidPrimitiveType.bool.syntax: return .bool
        case CandidPrimitiveType.natural.syntax: return .natural
        case CandidPrimitiveType.integer.syntax: return .integer
        case CandidPrimitiveType.natural8.syntax: return .natural8
        case CandidPrimitiveType.natural16.syntax: return .natural16
        case CandidPrimitiveType.natural32.syntax: return .natural32
        case CandidPrimitiveType.natural64.syntax: return .natural64
        case CandidPrimitiveType.integer8.syntax: return .integer8
        case CandidPrimitiveType.integer16.syntax: return .integer16
        case CandidPrimitiveType.integer32.syntax: return .integer32
        case CandidPrimitiveType.integer64.syntax: return .integer64
        case CandidPrimitiveType.float32.syntax: return .float32
        case CandidPrimitiveType.float64.syntax: return .float64
        case CandidPrimitiveType.text.syntax: return .text
        case CandidPrimitiveType.reserved.syntax: return .reserved
        case CandidPrimitiveType.empty.syntax: return .empty
        case CandidPrimitiveType.principal.syntax: return .principal
        case CandidPrimitiveType.option.syntax: return .option(try parseCandidType(stream))
        case CandidPrimitiveType.vector.syntax: return .vector(try parseCandidType(stream))
        case CandidPrimitiveType.record.syntax: return .record(try parseRecordKeyedTypes(stream))
        case CandidPrimitiveType.variant.syntax: return .variant(try parseVariantKeyedTypes(stream))
        case CandidPrimitiveType.function.syntax: return .function(try parseFunctionSignature(stream))
        case CandidPrimitiveType.service.syntax: return .service(try parseServiceSignature(stream))
        case "blob": return .blob
        default: return .named(type)
        }
    }
    
    // record {}
    // record { first_name : text; second_name : text }
    // record { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // record { text; text; opt bool }
    private func parseRecordKeyedTypes(_ stream: CandidParserStream) throws -> [CandidKeyedType] {
        let items = try Self.parseEnclosedItems(.brackets, .semicolon, stream, parseOptionalNamedType)
            .enumerated()
            .map {
                guard let name = $0.element.0 else {
                    return CandidKeyedType($0.offset, $0.element.1)
                }
                if let number = Int(name, radix: 10) {
                    return CandidKeyedType(number, $0.element.1)
                }
                return CandidKeyedType(name, $0.element.1)
            }
        return items
    }
    
    /// (<name> :)? <type>
    private func parseOptionalNamedType(_ stream: CandidParserStream) throws -> (String?, CandidType) {
        let name: String?
        if try stream.peekSecondNext() == .colon {
            name = try stream.expectNextTextOrWord()
            try stream.expectNext(.colon)
        } else {
            name = nil
        }
        let type = try parseCandidType(stream)
        return (name, type)
    }
    
    // variant {}
    // variant { ok : nat; error : text }
    // variant { "name with spaces" : nat; "unicode, too: ☃" : bool }
    // variant { spring; summer; fall; winter }
    private func parseVariantKeyedTypes(_ stream: CandidParserStream) throws -> [CandidKeyedType] {
        return try Self.parseEnclosedItems(.brackets, .semicolon, stream, parseVariantKeyedType)
    }
    
    /// <name> (: <type>)?
    private func parseVariantKeyedType(_ stream: CandidParserStream) throws -> CandidKeyedType {
        let token = try stream.peekNext()
        let label = try stream.expectNextTextOrWord()
        let key: CandidKey
        if case .word = token, let number = Int(label, radix: 10) {
            key = CandidKey(number)
        } else {
            // Quoted numeric labels are text keys, not numeric field IDs.
            key = CandidKey(label)
        }
        let nextToken = try stream.peekNext()
        if nextToken == .colon {
            try stream.expectNext(.colon)
            let keyType = try parseCandidType(stream)
            return CandidKeyedType(key, keyType)
        }
        return CandidKeyedType(key, .null)
    }
    
    /// func () -> ()
    /// func (text) -> (text)
    /// func (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    /// func () -> (int) query
    /// func (func (int) -> ()) -> ()
    ///
    /// func <functype>
    /// <functype>  ::= <tuptype> -> <tuptype> <funcann>*
    /// <funcann>   ::= oneway | query | composite_query
    /// <tuptype>   ::= ( <argtype>,* )
    private func parseFunctionSignature(_ stream: CandidParserStream) throws -> CandidFunctionSignature {
        let inputs = try parseFunctionParameters(stream)
        try stream.expectNext(.rightArrow)
        let outputs = try parseFunctionParameters(stream)
        let query = try stream.takeIfNext(is: .word("query"))
        let oneway = try stream.takeIfNext(is: .word("oneway"))
        let compositeQuery = try stream.takeIfNext(is: .word("composite_query"))
        return CandidFunctionSignature(inputs, outputs, query: query, oneWay: oneway, compositeQuery: compositeQuery)
    }
    
    private func parseFunctionParameters(_ stream: CandidParserStream) throws -> [CandidFunctionSignature.Parameter] {
        let parameters = try Self.parseEnclosedItems(.parenthesis, .comma, stream, parseOptionalNamedType)
            .enumerated()
            .map { CandidFunctionSignature.Parameter(index: $0.offset, name: $0.element.0, type: $0.element.1) }
        return parameters
    }
    
    /// <actor> ::= service <id>? : (<tuptype> ->)? (<actortype> | <id>) ;?
    /// <actortype> ::= { <methtype>;* }
    private func parseServiceDefinition(_ stream: CandidParserStream) throws -> CandidInterfaceDefinition.ServiceDefinition {
        let serviceName: String?
        if try stream.peekNext().isTextOrId {
            serviceName = try stream.expectNextTextOrWord()
        } else {
            serviceName = nil
        }
        try stream.expectNext(.colon)
        
        let initialisationParameters: [CandidFunctionSignature.Parameter]?
        if (try stream.peekNext() == .openParenthesis) {
            // ignore any service initialisation parameters. We can't use them from a mobile device
            initialisationParameters  = try parseFunctionParameters(stream)
            try stream.expectNext(.rightArrow)
        } else {
            initialisationParameters = nil
        }
        
        let serviceSignature: CandidInterfaceDefinition.ServiceDefinition.SignatureType
        if try stream.peekNext() == .openBracket {
            serviceSignature = .concrete(try parseServiceSignature(stream))
        } else {
            let typeName = try stream.expectNextId()
            serviceSignature = .reference(typeName)
        }
        if stream.hasNext {
            try stream.expectNext(.semicolon)
        }
        let originalDefinition = stream.originalStringSinceLastMarker()
        return CandidInterfaceDefinition.ServiceDefinition(
            name: serviceName,
            initialisationArguments: initialisationParameters, 
            signature: serviceSignature,
            originalDefinition: originalDefinition
        )
    }
    
    /// service {
    ///     set_address: (name : text, addr : address) -> ();
    ///     get_address: (name : text) -> (opt address) query;
    /// }
    /// service {
    ///    reverse : (text) -> (text);
    ///    divMod : (dividend : nat, divisor : nat) -> (div : nat, mod : nat);
    /// }
    /// service {
    ///    authorize : (principal, Auth) -> (success : bool);
    /// };
    /// type A = service { f : () -> (); };
    /// type F = function () -> ();
    /// type S = service { foo: F; };
    ///
    /// <actortype> ::= { <methtype>;* }
    /// <methtype>  ::= <name> : (<functype> | <id>)
    private func parseServiceSignature(_ stream: CandidParserStream) throws -> CandidServiceSignature {
        try stream.expectNext(.openBracket)
        var token = try stream.takeNext()
        var methods: [CandidServiceSignature.Method] = []
        while token != .closeBracket {
            let methodName = try stream.expectCurrentTextOrWord()
            try stream.expectNext(.colon)
            let signatureType: CandidServiceSignature.Method.FunctionSignatureType
            if try stream.peekNext() == .openParenthesis {
                let methodSignature = try parseFunctionSignature(stream)
                signatureType = .concrete(methodSignature)
            } else {
                let name = try stream.expectNextId()
                signatureType = .reference(name)
            }
            try stream.expectNext(.semicolon)
            token = try stream.takeNext()
            methods.append(.init(name: methodName, signatureType: signatureType))
        }
        return CandidServiceSignature(methods)
    }
}

private class ParsingContext {
    private(set) var namedTypes: [CandidNamedType] = []
    private(set) var service: CandidInterfaceDefinition.ServiceDefinition?
    
    subscript (_ name: String) -> CandidType? {
        return namedTypes[name]
    }
    
    func defineType(_ name: String, _ type: CandidType, _ originalString: String) throws {
        guard !contains(name) else {
            throw CandidParserError.typeAlreadyDefined(name)
        }
        namedTypes.append(.init(name: name, type: type, originalDefinition: originalString))
    }
    
    func add(_ namedType: CandidNamedType) throws {
        guard !contains(namedType.name) else {
            throw CandidParserError.typeAlreadyDefined(namedType.name)
        }
        namedTypes.append(namedType)
    }
    
    func setService(_ service: CandidInterfaceDefinition.ServiceDefinition) throws {
        guard self.service == nil else {
            throw CandidParserError.redundantService(service.name ?? "(unnamed)")
        }
        self.service = service
    }
        
    func contains(_ name: String) -> Bool { namedTypes.contains(name) }
}
