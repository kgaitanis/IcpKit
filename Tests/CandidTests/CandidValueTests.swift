import Foundation
import BigInt
import Testing
@testable import Candid

struct CandidValueTests {
    @Test(arguments: primitiveInitializerCases)
    func primitiveInitializersPreserveTypesAndValues(
        _ makeValue: @Sendable () -> CandidValue, _ expected: CandidValue
    ) {
        #expect(makeValue() == expected)
        #expect(makeValue().candidType == expected.candidType)
    }

    @Test(arguments: accessorCases)
    fileprivate func accessorsReturnOnlyMatchingValues(_ fixture: AccessorCase) throws {
        let value = try fixture.makeValue()
        #expect(fixture.read(value) == value)
        #expect(fixture.read(.null) == nil)
    }

    @Test(arguments: valueCases)
    fileprivate func valuesPreserveTypeAndDescription(_ fixture: ValueCase) throws {
        let value = try fixture.makeValue()
        #expect(value.candidType == fixture.type)
        #expect(value.description == fixture.description)
    }

    @Test(arguments: typeSyntaxCases)
    func typeSyntaxCanBeParsedBack(_ type: CandidType, _ syntax: String) throws {
        #expect(type.syntax == syntax)
        if case .named = type { return }
        #expect(try CandidParser().parseSingleType(syntax) == type)
    }

    @Test func functionSyntaxPreservesParametersAndNames() throws {
        let signature = CandidFunctionSignature(
            [("owner", CandidType.principal), (nil, .option(.natural))],
            [("balance", CandidType.natural), (nil, .text)],
            query: true
        )
        let type = CandidType.function(signature)
        #expect(type.syntax == "func (owner: principal, opt nat) -> (balance: nat, text) query")
        let parsed = try CandidParser().parseSingleType(type.syntax)
        #expect(parsed == type)
        guard case .function(let result) = parsed else {
            Issue.record("Expected function")
            return
        }
        // Parameter equality ignores names, so verify them separately.
        #expect(result.arguments.map(\.name) == ["owner", nil])
        #expect(result.results.map(\.name) == ["balance", nil])
    }

    @Test(arguments: ["", "query", "oneway", "composite_query"])
    func functionAndServiceSyntaxPreserveAnnotations(_ annotation: String) throws {
        let signature = CandidFunctionSignature(
            [CandidType.text], [CandidType](),
            query: annotation == "query",
            oneWay: annotation == "oneway",
            compositeQuery: annotation == "composite_query"
        )
        let suffix = annotation.isEmpty ? "" : " " + annotation
        let function = CandidType.function(signature)
        let service = CandidType.service(CandidServiceSignature([
            .init(name: "notify", functionSignature: signature)
        ]))
        #expect(function.syntax == "func (text) -> ()" + suffix)
        #expect(service.syntax == "service { notify: (text) -> ()" + suffix + "; }")
        #expect(try CandidParser().parseSingleType(function.syntax) == function)
        #expect(try CandidParser().parseSingleType(service.syntax) == service)
    }

    @Test func serviceSyntaxPreservesMultipleMethodsAndReferences() throws {
        let type = CandidType.service(CandidServiceSignature([
            .init("balance", [.principal], [.natural], query: true),
            .init("transfer", [.principal, .natural], [.bool]),
            .init(name: "callback", signatureReference: "Callback")
        ]))
        #expect(type.syntax == "service { balance: (principal) -> (nat) query; transfer: (principal, nat) -> (bool); callback: Callback; }")
        #expect(try CandidParser().parseSingleType(type.syntax) == type)
    }

    @Test func serviceSyntaxPreservesNestedFunctionAndServiceTypes() throws {
        let callback = CandidType.function(CandidFunctionSignature([CandidType.text], [.bool], query: true))
        let child = CandidType.service(CandidServiceSignature([.init("ping", [CandidType](), [])]))
        let type = CandidType.service(CandidServiceSignature([
            .init("register", [callback], [child])
        ]))
        #expect(type.syntax == "service { register: (func (text) -> (bool) query) -> (service { ping: () -> (); }); }")
        #expect(try CandidParser().parseSingleType(type.syntax) == type)
    }

    @Test func serviceSyntaxQuotesKeywordNames() throws {
        let signature = CandidFunctionSignature(
            [("type", CandidType.text)], [("true", CandidType.bool)]
        )
        let type = CandidType.service(CandidServiceSignature([
            .init(name: "query", functionSignature: signature)
        ]))
        #expect(type.syntax == #"service { "query": ("type": text) -> ("true": bool); }"#)
        #expect(try CandidParser().parseSingleType(type.syntax) == type)
    }

    @Test func serviceSyntaxEscapesSpecialCharactersInNames() {
        let signature = CandidFunctionSignature([CandidType](), [])
        let type = CandidType.service(CandidServiceSignature([
            .init(name: "notify\n", functionSignature: signature),
            .init(name: "quote\"slash\\", functionSignature: signature)
        ]))
        #expect(type.syntax == #"service { "notify\n": () -> (); "quote\"slash\\": () -> (); }"#)
    }

    @Test func serviceSyntaxQuotesMethodAndParameterNames() throws {
        let signature = CandidFunctionSignature(
            [("account owner", CandidType.principal)],
            [("token balance", CandidType.natural)],
            query: true
        )
        let type = CandidType.service(CandidServiceSignature([
            .init(name: "get balance", functionSignature: signature)
        ]))
        #expect(type.syntax == #"service { "get balance": ("account owner": principal) -> ("token balance": nat) query; }"#)
        #expect(try CandidParser().parseSingleType(type.syntax) == type)
    }

    @Test func serviceTypeAndCanisterDeclarationUseDifferentColonSyntax() async throws {
        let parser = CandidParser()
        #expect(try parser.parseSingleType("service {}") == .service())
        #expect(throws: CandidParserError.self) {
            try parser.parseSingleType("service: {}")
        }
        let declaration = try await parser.parseInterfaceDescription("service: {}")
        #expect(declaration.service != nil)
        await #expect(throws: CandidParserError.self) {
            _ = try await parser.parseInterfaceDescription("service {}")
        }
    }

    @Test func variantLabelsPreserveNumericAndQuotedKeys() throws {
        let cases: [(String, [CandidKeyedType])] = [
            ("variant { 0: null; 1: text }", [.init(0, .null), .init(1, .text)]),
            (#"variant { "0": null; "1": text }"#, [.init("0", .null), .init("1", .text)]),
            (#"variant { 0; "0": text; ok: bool }"#, [.init(0, .null), .init("0", .text), .init("ok", .bool)]),
            ("variant { 0; ok }", [.init(0, .null), .init("ok", .null)])
        ]
        for (syntax, expected) in cases {
            let parsed = try CandidParser().parseSingleType(syntax)
            guard case .variant(let fields) = parsed else {
                Issue.record("Expected variant for \(syntax)")
                continue
            }
            let actual = fields.items.sorted()
            let expected = expected.sorted()
            #expect(actual == expected, "\(syntax)")
            // Equality compares numeric IDs; also check that quoted labels retain their names.
            #expect(actual.map(\.key.stringValue) == expected.map(\.key.stringValue), "\(syntax)")
        }
    }

    @Test(arguments: typeInitializerCases)
    func typeInitializersPreserveFields(_ actual: CandidType, _ expected: CandidType) {
        #expect(actual == expected)
    }

    @Test(arguments: recordCases)
    func recordsSortKeysAndLookUpFields(_ record: CandidRecord) {
        #expect(record.candidValues == [.bool(true), .text("second")])
        #expect(record.candidSortedItems.map(\.key.intValue) == [97, 98])
        #expect(record.candidTypes == [.init(97, .bool), .init(98, .text)])
        #expect(record["a"] == .bool(true))
        #expect(record[98] == .text("second"))
        #expect(record["missing"] == nil)
        #expect(record[99] == nil)
    }

    @Test(arguments: keyedTypeCases)
    func keyedTypesSortAndLookUpFields(_ types: CandidKeyedTypes) {
        #expect(types.items.map(\.key.intValue) == [97, 98])
        #expect(types.count == 2)
        #expect(Array(types) == types.items)
        #expect(types[97]?.type == .bool)
        #expect(types[98]?.type == .text)
        #expect(types[CandidKey("a")]?.type == .bool)
        #expect(types[CandidKey(99)] == nil)
        #expect(types["missing"] == nil)
        #expect(types[99] == nil)
    }

    @Test(arguments: variantCases)
    func variantsLookUpOnlyTheSelectedCase(_ makeVariant: @Sendable () throws -> CandidVariant) throws {
        let variant = try makeVariant()
        #expect(variant.valueIndex == 1)
        #expect(variant.key == CandidKey("b"))
        #expect(variant["b"] == .text("yes"))
        #expect(variant[98] == .text("yes"))
        #expect(variant["a"] == nil)
        #expect(variant[99] == nil)
    }

    @Test(arguments: invalidVariantCases)
    func variantsRejectMissingKeys(_ makeVariant: @Sendable () throws -> CandidValue) {
        #expect(throws: CandidVariantError.valueNotPartOfTypes) { try makeVariant() }
    }

    @Test(arguments: invalidVectorCases)
    func vectorsRejectEmptyOrIncompatibleInputs(_ makeVector: @Sendable () throws -> CandidVector) {
        // The implementation's error enum is private.
        #expect(throws: (any Error).self) { try makeVector() }
    }

    @Test(arguments: optionCases)
    func optionsPreserveContainedType(_ option: CandidOption, _ type: CandidType, _ value: CandidValue?) {
        #expect(option.containedType == type)
        #expect(option.value == value)
    }

    @Test(arguments: principalCases)
    func principalsValidateAndRoundTrip(_ string: String, _ bytes: Data) throws {
        #expect(CandidPrincipal.isValid(string))
        let principal = try CandidPrincipal(string)
        #expect(principal.bytes == bytes)
        #expect(principal.string == string)
        #expect(principal.description == string)
        #expect(CandidPrincipal(bytes) == principal)
        #expect(try CandidValue.principal(string).principalValue == principal)
        #expect(CandidValue.principal(bytes).principalValue == principal)
    }

    @Test(arguments: invalidPrincipalCases)
    func principalsRejectInvalidText(_ string: String) {
        #expect(!CandidPrincipal.isValid(string))
        #expect(throws: (any Error).self) { try CandidPrincipal(string) }
    }

    @Test(arguments: keyCases)
    func keysUseHashedIdentity(_ named: CandidKey, _ numeric: CandidKey) {
        #expect(named.hasString)
        #expect(!numeric.hasString)
        #expect(named == numeric)
        #expect(Set([named, numeric]).count == 1)
        #expect(!(named < numeric))
    }

    @Test(arguments: signatureCases)
    func signaturesSortParametersAndPreserveAnnotations(_ signature: CandidFunctionSignature) {
        #expect(signature.arguments.map(\.index) == [0, 1])
        #expect(signature.arguments.map(\.type) == [.bool, .text])
        #expect(signature.results.map(\.index) == [0, 1])
        #expect(signature.results.map(\.type) == [.natural, .integer])
        #expect(signature.annotations == signatureAnnotations)
    }

    @Test(arguments: parameterEqualityCases)
    func parameterNamesDoNotAffectIdentity(
        _ lhs: CandidFunctionSignature.Parameter,
        _ rhs: CandidFunctionSignature.Parameter,
        _ equal: Bool
    ) {
        #expect((lhs == rhs) == equal)
        #expect((lhs < rhs) == (lhs.index < rhs.index))
    }

    @Test(arguments: functionCases)
    func functionReferencesPreserveSignatures(_ makeFunction: @Sendable () throws -> CandidValue) throws {
        let function = try #require(try makeFunction().functionValue)
        #expect(function.signature == referenceSignature)
        #expect(function.method?.name == "lookup")
        #expect(function.method?.principal == managementPrincipal)
        #expect(function.description.hasPrefix("aaaaa-aa.lookup "))
    }

    @Test(arguments: serviceCases)
    func serviceReferencesPreserveSignatures(_ makeService: @Sendable () throws -> CandidValue) throws {
        let service = try #require(try makeService().serviceValue)
        #expect(service.signature.methods == referenceMethods)
        #expect(service.principal == managementPrincipal)
    }

    @Test func unboundReferencesPreserveSignatures() throws {
        let function = try #require(unboundFunction.functionValue)
        #expect(function.signature == referenceSignature)
        #expect(function.method == nil)
        #expect(function.description == referenceSignature.description)
        let named = try #require(namedFunction.functionValue)
        #expect(named.signature.arguments.first?.name == "flag")
        #expect(named.signature.annotations.oneWay)
        let service = try #require(unboundService.serviceValue)
        #expect(service.principal == nil)
        #expect(service.signature.methods == referenceMethods)
        #expect(service.signature.description.contains("lookup:"))
    }
}

private struct AccessorCase: Sendable {
    let makeValue: @Sendable () throws -> CandidValue
    let read: @Sendable (CandidValue) -> CandidValue?
}

private let accessorCases: [AccessorCase] = [
    .init(makeValue: { .bool(true) }, read: { $0.boolValue.map(CandidValue.bool) }),
    .init(makeValue: { .text("hello") }, read: { $0.textValue.map(CandidValue.text) }),
    .init(makeValue: { .blob(Data([0, 255])) }, read: { $0.blobValue.map(CandidValue.blob) }),
    .init(makeValue: { .natural8(255) }, read: { $0.natural8Value.map(CandidValue.natural8) }),
    .init(makeValue: { .natural16(65535) }, read: { $0.natural16Value.map(CandidValue.natural16) }),
    .init(makeValue: { .natural32(4294967295) }, read: { $0.natural32Value.map(CandidValue.natural32) }),
    .init(makeValue: { .natural64(.max) }, read: { $0.natural64Value.map(CandidValue.natural64) }),
    .init(makeValue: { .integer8(.min) }, read: { $0.integer8Value.map(CandidValue.integer8) }),
    .init(makeValue: { .integer16(.min) }, read: { $0.integer16Value.map(CandidValue.integer16) }),
    .init(makeValue: { .integer32(.min) }, read: { $0.integer32Value.map(CandidValue.integer32) }),
    .init(makeValue: { .integer64(.min) }, read: { $0.integer64Value.map(CandidValue.integer64) }),
    .init(makeValue: { .integer(-123456789) }, read: { $0.integerValue.map(CandidValue.integer) }),
    .init(makeValue: { .natural(123456789) }, read: { $0.naturalValue.map(CandidValue.natural) }),
    .init(makeValue: { .float32(1.5) }, read: { $0.float32Value.map(CandidValue.float32) }),
    .init(makeValue: { .float64(-2.5) }, read: { $0.float64Value.map(CandidValue.float64) }),
    .init(makeValue: { .option(.bool(true)) }, read: { $0.optionValue.map(CandidValue.option) }),
    .init(makeValue: { try .vector([.bool(true)]) }, read: { $0.vectorValue.map(CandidValue.vector) }),
    .init(makeValue: { .record(["a": .bool(true)]) }, read: { $0.recordValue.map(CandidValue.record) }),
    .init(makeValue: { try .variant(["a": .bool], ("a", .bool(true))) }, read: { $0.variantValue.map(CandidValue.variant) }),
    .init(makeValue: { unboundFunction }, read: { $0.functionValue.map(CandidValue.function) }),
    .init(makeValue: { unboundService }, read: { $0.serviceValue.map(CandidValue.service) }),
    .init(makeValue: { .principal(managementPrincipal) }, read: { $0.principalValue.map { .principal($0) } }),
]

private struct ValueCase: Sendable {
    let makeValue: @Sendable () throws -> CandidValue
    let type: CandidType
    let description: String
}

private let valueCases: [ValueCase] = [
    .init(makeValue: { .null }, type: .null, description: "null"),
    .init(makeValue: { .bool(false) }, type: .bool, description: "false"),
    .init(makeValue: { .natural(42) }, type: .natural, description: "42"),
    .init(makeValue: { .integer(-42) }, type: .integer, description: "-42"),
    .init(makeValue: { .natural8(1) }, type: .natural8, description: "1 : nat8"),
    .init(makeValue: { .natural16(2) }, type: .natural16, description: "2 : nat16"),
    .init(makeValue: { .natural32(3) }, type: .natural32, description: "3 : nat32"),
    .init(makeValue: { .natural64(4) }, type: .natural64, description: "4 : nat64"),
    .init(makeValue: { .integer8(-1) }, type: .integer8, description: "-1 : int8"),
    .init(makeValue: { .integer16(-2) }, type: .integer16, description: "-2 : int16"),
    .init(makeValue: { .integer32(-3) }, type: .integer32, description: "-3 : int32"),
    .init(makeValue: { .integer64(-4) }, type: .integer64, description: "-4 : int64"),
    .init(makeValue: { .float32(1.5) }, type: .float32, description: "1.5 : float32"),
    .init(makeValue: { .float64(-2.5) }, type: .float64, description: "-2.5"),
    .init(makeValue: { .text("hello") }, type: .text, description: "hello"),
    .init(makeValue: { .blob(Data([0, 255])) }, type: .blob, description: "blob \"00ff\""),
    .init(makeValue: { .reserved }, type: .reserved, description: "reserved"),
    .init(makeValue: { .empty }, type: .empty, description: "empty"),
    .init(makeValue: { .option(.bool(true)) }, type: .option(.bool), description: "opt true"),
    .init(makeValue: { .option(CandidType.bool) }, type: .option(.bool), description: "opt null: bool"),
    .init(makeValue: { .vector(.bool) }, type: .vector(.bool), description: "vec bool {}"),
    .init(makeValue: { try .vector([.bool(true), .bool(false)]) }, type: .vector(.bool), description: "vec bool {true; false}"),
    .init(makeValue: { .record(["a": .bool(true)]) }, type: .record(["a": .bool]), description: "record {\n\ta = true}"),
    .init(makeValue: { .record([0: .bool(true)]) }, type: .record([0: .bool]), description: "record {\n\t0 = true}"),
    .init(makeValue: { .variant(.init("a", .bool(true))) }, type: .variant(["a": .bool]), description: "variant {a: true}"),
    .init(makeValue: { try .variant([0: .bool], .bool(true), 0) }, type: .variant([0: .bool]), description: "variant {0: true}"),
    .init(makeValue: { .principal(nil) }, type: .principal, description: "principal \"\""),
    .init(makeValue: { .principal(managementPrincipal) }, type: .principal, description: "principal \"aaaaa-aa\""),
    .init(makeValue: { .service([]) }, type: .service(), description: "service: \"\""),
    .init(makeValue: { try .service("aaaaa-aa") }, type: .service(), description: "service: \"aaaaa-aa\""),
    .init(makeValue: { .function([CandidType](), []) }, type: .function(), description: "function () -> ()   "),
]

private let typeInitializerCases: [(CandidType, CandidType)] = [
    (.variant(("a", .bool), ("b", .text)), .variant([.init(97, .bool), .init(98, .text)])),
    (.variant("b", "a"), .variant(["a": .null, "b": .null])),
    (.variant([2: .text, 0: .bool]), .variant([.init(0, .bool), .init(2, .text)])),
    (.record(("b", .text), ("a", .bool)), .record([.init(97, .bool), .init(98, .text)])),
    (.record([.bool, .text]), .record([0: .bool, 1: .text])),
    (.service(["lookup": referenceSignature]), .service(referenceMethods)),
]

private let recordCases: [CandidRecord] = [
    CandidRecord(["b": .text("second"), "a": .bool(true)]),
    CandidRecord([98: .text("second"), 97: .bool(true)]),
    CandidRecord([CandidKeyedValue("b", .text("second")), .init("a", .bool(true))]),
    ["b": .text("second"), "a": .bool(true)],
]

private let keyedTypeCases: [CandidKeyedTypes] = [
    [.init("b", .text), .init("a", .bool)],
    CandidKeyedTypes([CandidKeyedType(CandidKey(98), .text), .init(CandidKey(97), .bool)]),
]

private let variantCases: [@Sendable () throws -> CandidVariant] = [
    { try CandidVariant(candidTypes: [("b", .text), ("a", .bool)], value: ("b", .text("yes"))) },
    { try CandidVariant(candidTypes: [.init(98, .text), .init(97, .bool)], value: .text("yes"), valueKey: 98) },
    { CandidVariant(candidTypes: [.init(98, .text), .init(97, .bool)], value: .text("yes"), valueIndex: 1) },
]

private let invalidVariantCases: [@Sendable () throws -> CandidValue] = [
    { try .variant(["a": .bool], ("b", .bool(true))) },
    { try .variant([0: .bool], .bool(true), 1) },
]

private let invalidVectorCases: [@Sendable () throws -> CandidVector] = [
    { try CandidVector([CandidValue]()) },
    { try CandidVector([.bool(true), .text("wrong")]) },
    { try CandidVector(.bool, [.text("wrong")]) },
]

private let optionCases: [(CandidOption, CandidType, CandidValue?)] = [
    (.none(.bool), .bool, nil),
    (.some(.bool(true)), .bool, .bool(true)),
    (.some(.option(CandidType.text)), .option(.text), .option(CandidType.text)),
]

private let principalCases: [(String, Data)] = [
    ("aaaaa-aa", Data()),
    ("2vxsx-fae", Data([4])),
]
private let invalidPrincipalCases = ["", "invalid!", "aaaaa-ab"]
private let managementPrincipal: CandidPrincipal = "aaaaa-aa"
private let keyCases: [(CandidKey, CandidKey)] = [
    (CandidKey("a"), CandidKey(97)),
    (CandidKey(""), CandidKey(0)),
]

private let signatureAnnotations = CandidFunctionSignature.Annotations(query: true, oneWay: false, compositeQuery: true)
private let signatureInputs: [CandidFunctionSignature.Parameter] = [
    .init(index: 1, name: "label", type: .text),
    .init(index: 0, name: "flag", type: .bool),
]
private let signatureOutputs: [CandidFunctionSignature.Parameter] = [
    .init(index: 1, name: "signed", type: .integer),
    .init(index: 0, name: "unsigned", type: .natural),
]
private let signatureCases = [
    CandidFunctionSignature(signatureInputs, signatureOutputs, signatureAnnotations),
    CandidFunctionSignature(signatureInputs, signatureOutputs, query: true, compositeQuery: true),
    CandidFunctionSignature([("flag", .bool), ("label", .text)], [("unsigned", .natural), ("signed", .integer)], query: true, compositeQuery: true),
    CandidFunctionSignature([CandidType.bool, .text], [.natural, .integer], query: true, compositeQuery: true),
]
private let parameterEqualityCases: [(CandidFunctionSignature.Parameter, CandidFunctionSignature.Parameter, Bool)] = [
    (.init(index: 0, name: "a", type: .bool), .init(index: 0, name: "b", type: .bool), true),
    (.init(index: 0, name: nil, type: .bool), .init(index: 1, name: nil, type: .bool), false),
    (.init(index: 0, name: nil, type: .bool), .init(index: 0, name: nil, type: .text), false),
]

private let referenceSignature = CandidFunctionSignature([CandidType.bool], [.text], query: true)
private let referenceMethods: [CandidServiceSignature.Method] = [.init(name: "lookup", functionSignature: referenceSignature)]
private let unboundFunction = CandidValue.function([CandidType.bool], [.text], query: true)
private let namedFunction = CandidValue.function([.init(index: 0, name: "flag", type: .bool)], [], oneWay: true)
private let unboundService = CandidValue.service(referenceMethods)
private let functionCases: [@Sendable () throws -> CandidValue] = [
    { try .function([.bool], [.text], query: true, "aaaaa-aa", "lookup") },
    { .function([.bool], [.text], query: true, managementPrincipal, "lookup") },
    { .function(CandidFunction(signature: referenceSignature, principal: managementPrincipal, methodName: "lookup")) },
]
private let serviceCases: [@Sendable () throws -> CandidValue] = [
    { .service(referenceMethods, managementPrincipal) },
    { try .service(referenceMethods, "aaaaa-aa") },
]

private let primitiveInitializerCases: [(@Sendable () -> CandidValue, CandidValue)] = [
    ({ CandidValue(Bool(true)) }, .bool(true)),
    ({ CandidValue(Bool?.some(true)) }, .option(.bool(true))),
    ({ CandidValue(Bool?.none) }, .option(CandidType.bool)),
    ({ CandidValue(String("hello")) }, .text("hello")),
    ({ CandidValue(String?.some("hello")) }, .option(.text("hello"))),
    ({ CandidValue(String?.none) }, .option(CandidType.text)),
    ({ CandidValue(Data(Data([0, 255]))) }, .blob(Data([0, 255]))),
    ({ CandidValue(Data?.some(Data([0, 255]))) }, .option(.blob(Data([0, 255])))),
    ({ CandidValue(Data?.none) }, .option(CandidType.blob)),
    ({ CandidValue(UInt8(255)) }, .natural8(255)),
    ({ CandidValue(UInt8?.some(255)) }, .option(.natural8(255))),
    ({ CandidValue(UInt8?.none) }, .option(CandidType.natural8)),
    ({ CandidValue(UInt16(65535)) }, .natural16(65535)),
    ({ CandidValue(UInt16?.some(65535)) }, .option(.natural16(65535))),
    ({ CandidValue(UInt16?.none) }, .option(CandidType.natural16)),
    ({ CandidValue(UInt32(4294967295)) }, .natural32(4294967295)),
    ({ CandidValue(UInt32?.some(4294967295)) }, .option(.natural32(4294967295))),
    ({ CandidValue(UInt32?.none) }, .option(CandidType.natural32)),
    ({ CandidValue(UInt64(18446744073709551615)) }, .natural64(18446744073709551615)),
    ({ CandidValue(UInt64?.some(18446744073709551615)) }, .option(.natural64(18446744073709551615))),
    ({ CandidValue(UInt64?.none) }, .option(CandidType.natural64)),
    ({ CandidValue(UInt(42)) }, .natural64(42)),
    ({ CandidValue(UInt?.some(42)) }, .option(.natural64(42))),
    ({ CandidValue(UInt?.none) }, .option(CandidType.natural64)),
    ({ CandidValue(Int8(-128)) }, .integer8(-128)),
    ({ CandidValue(Int8?.some(-128)) }, .option(.integer8(-128))),
    ({ CandidValue(Int8?.none) }, .option(CandidType.integer8)),
    ({ CandidValue(Int16(-32768)) }, .integer16(-32768)),
    ({ CandidValue(Int16?.some(-32768)) }, .option(.integer16(-32768))),
    ({ CandidValue(Int16?.none) }, .option(CandidType.integer16)),
    ({ CandidValue(Int32(-2147483648)) }, .integer32(-2147483648)),
    ({ CandidValue(Int32?.some(-2147483648)) }, .option(.integer32(-2147483648))),
    ({ CandidValue(Int32?.none) }, .option(CandidType.integer32)),
    ({ CandidValue(Int64(-9223372036854775808)) }, .integer64(-9223372036854775808)),
    ({ CandidValue(Int64?.some(-9223372036854775808)) }, .option(.integer64(-9223372036854775808))),
    ({ CandidValue(Int64?.none) }, .option(CandidType.integer64)),
    ({ CandidValue(Int(-42)) }, .integer64(-42)),
    ({ CandidValue(Int?.some(-42)) }, .option(.integer64(-42))),
    ({ CandidValue(Int?.none) }, .option(CandidType.integer64)),
    ({ CandidValue(BigInt(-123456789)) }, .integer(-123456789)),
    ({ CandidValue(BigInt?.some(-123456789)) }, .option(.integer(-123456789))),
    ({ CandidValue(BigInt?.none) }, .option(CandidType.integer)),
    ({ CandidValue(BigUInt(123456789)) }, .natural(123456789)),
    ({ CandidValue(BigUInt?.some(123456789)) }, .option(.natural(123456789))),
    ({ CandidValue(BigUInt?.none) }, .option(CandidType.natural)),
]

private let typeSyntaxCases: [(CandidType, String)] = [
    (.bool, "bool"),
    (.option(.vector(.natural8)), "opt vec nat8"),
    (.record(["a": .bool, "b": .text]), "record { a: bool; b: text}"),
    (.variant([0: .null, 1: .text]), "variant { 0: null; 1: text}"),
    (.function(), "func () -> ()"),
    (.service(), "service {}"),
    (.named("Alias"), "Alias"),
]
