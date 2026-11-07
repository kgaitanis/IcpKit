//
//  CodeGeneratorTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation
import Testing
import Candid
@testable import CodeGenerator

struct CodeGeneratorTests {
    @Test(arguments: ["LedgerCanister", "ICRC7", "GoldNFT", "TestImports"])
    func `Type DID files`(file: String) async throws {
        let did = file + ".did"
        let interface = try await CandidParser().parseInterfaceDescription(BundleDidProvider(main: did))
        let generated = try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: file)
        let swiftPath = try #require(Bundle.module.url(forResource: did, withExtension: "generated_swift"))
        let swiftFile = try String(contentsOf: swiftPath, encoding: .utf8)
        #expect(generated == swiftFile)
    }

    @Test(arguments: ["EVMProviders"])
    func `Value DID files`(file: String) throws {
        let path = try #require(Bundle.module.url(forResource: file, withExtension: "did"))
        let didFile = try String(contentsOf: path, encoding: .utf8)
        let parsed = try CandidParser().parseValue(didFile)
        let generated = try CandidCodeGenerator().generateSwiftCode(for: parsed, valueName: file)
        let swiftPath = try #require(Bundle.module.url(forResource: file, withExtension: "did.generated_swift"))
        let swiftFile = try String(contentsOf: swiftPath, encoding: .utf8)
        #expect(generated == swiftFile)
    }

    private static let valueTestVectors: [(CandidValue, String)] = [
            (.integer8(2), "let cValue: Int8 = 2"),
            (try! .vector([.integer8(1), .integer8(2), .integer8(3)]), "let cValue: [Int8] = [\n\t1,\n\t2,\n\t3,\n]\n"),
            (.record(["a": .integer(3), "b": .option(.blob(Data.fromHex("DEADBEEF")!))]), "struct UnnamedType0: Codable {\n\tlet a: BigInt\n\tlet b: Data?\n}\n\nlet cValue: UnnamedType0 = .init(\n\ta: 3,\n\tb: Data.fromHex(\"deadbeef\")!\n)"),
            (.record([0: .integer(3), 1: .option(.blob(Data.fromHex("DEADBEEF")!))]), """
let cValue: CandidTuple2<BigInt, Data?> = .init(
\t3,
\tData.fromHex("deadbeef")!
)
"""),
            (try! .variant(["a": .null, "b": .integer8], ("a", .null)), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t}
}

let cValue: UnnamedType0 = .a
"""),
            (try! .variant(["a": .null, "b": .integer8], ("b", .integer8(2))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t}
}

let cValue: UnnamedType0 = .b(2)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record([0:.bool, 1:.integer8])], ("c", .record([0:.bool(true), 1: .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(Bool, Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t\tcase c
\t}
}

let cValue: UnnamedType0 = .c(true, 7)
"""),
            (try! .variant(["a": .null, "b": .integer8, "c": .record(["bool":.bool, "int8":.integer8])], ("c", .record(["bool":.bool(true), "int8": .integer8(7)]))), """
enum UnnamedType0: Codable {
\tcase a
\tcase b(Int8)
\tcase c(bool: Bool, int8: Int8)

\tenum CodingKeys: String, CandidCodingKey {
\t\tcase a
\t\tcase b
\t\tcase c
\t}
\tenum CCodingKeys: String, CandidCodingKey {
\t\tcase bool
\t\tcase int8
\t}
}

let cValue: UnnamedType0 = .c(bool: true, int8: 7)
"""),
            (try! .function([], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCallNoArgs<[Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
            (try! .function([.vector(.bool)], [], "aaaaa-aa", "foo"), "let cValue: ICPCallNoResult<[Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], "aaaaa-aa", "foo"), "let cValue: ICPCall<[Bool], [Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
            (try! .function([], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoArgs<[Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
            (try! .function([.vector(.bool)], [], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQueryNoResult<[Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
            (try! .function([.vector(.bool)], [.vector(.bool)], query: true, "aaaaa-aa", "foo"), "let cValue: ICPQuery<[Bool], [Bool]> = .init(\"aaaaa-aa\", \"foo\")"),
    ]

    @Test(arguments: valueTestVectors)
    func `Generate value`(input: CandidValue, expected: String) throws {
        let generated = try CandidCodeGenerator(.init(generateHeader: false)).generateSwiftCode(for: input, valueName: "cValue")
        #expect(generated == expected)
    }
    
    @Test func icrc7() async throws {
        // GoldNFT io7gn-vyaaa-aaaak-qcbiq-cai
        let service = try ICRC7.Service("io7gn-vyaaa-aaaak-qcbiq-cai")
        let collectionMetadata = try await service.icrc7_collection_metadata()
        for metadata in collectionMetadata {
            print(metadata.tuple)
        }
        print("------------")
        let tokens = try await service.icrc7_tokens(prev: nil, take: nil)
        let metadataResponse = try await service.icrc7_token_metadata(token_ids: tokens)
        let firstMetadata = try #require(metadataResponse.first)
        let tokenMetadata = try #require(firstMetadata)
        for metadata in tokenMetadata {
            print(metadata._0)
            print(metadata._1)
            print("---")
        }
    }
}

private class BundleDidProvider: CandidInterfaceDefinitionProvider {
    let main: String
    init(main: String) {
        self.main = main
    }
    
    func readMain() async throws -> String {
        try getBundle(main)
    }
    
    func read(contentsOf file: String) async throws -> String {
        try getBundle(file)
    }
    
    private func getBundle(_ name: String) throws -> String {
        let path = try #require(Bundle.module.url(forResource: name, withExtension: nil))
        let didFile = try String(contentsOf: path)
        return didFile
    }
}

struct CodeGeneratorEdgeCaseTests {
    @Test func commandsWriteGeneratedTypeAndValueFiles() async throws {
        // Use a unique relative directory because the commands resolve paths against cwd.
        let directoryName = "CodeGeneratorTests-" + UUID().uuidString
        let directory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(directoryName)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: directory) }
        let typeInput = "type Flag = bool;"
        let valueInput = "true"
        try typeInput.write(to: directory.appendingPathComponent("types.did"), atomically: true, encoding: .utf8)
        try valueInput.write(to: directory.appendingPathComponent("value.did"), atomically: true, encoding: .utf8)

        var typeCommand = try CodeGenerator.GenerateType.parse(["--name", "Example", directoryName + "/types.did"])
        try await typeCommand.run()
        var valueCommand = try CodeGenerator.GenerateValue.parse(["--name", "flag", directoryName + "/value.did"])
        try valueCommand.run()

        let typeOutput = try String(contentsOf: directory.appendingPathComponent("types.did.swift"), encoding: .utf8)
        let valueOutput = try String(contentsOf: directory.appendingPathComponent("value.did.swift"), encoding: .utf8)
        let interface = try await CandidParser().parseInterfaceDescription(typeInput)
        #expect(typeOutput == (try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "Example")))
        #expect(valueOutput == (try CandidCodeGenerator().generateSwiftCode(for: .bool(true), valueName: "flag")))
    }

    @Test func mixedRecordLabelsGenerateInitializerAndCodingKeys() throws {
        let interface = CandidInterfaceDefinition(namedTypes: [
            "Mixed": .record([.init(7, .bool), .init("label", .text)])
        ])
        let code = try CandidCodeGenerator(.init(generateHeader: false))
            .generateSwiftCode(for: interface, nameSpace: "Example")
        #expect(code.contains("let _7: Bool"))
        #expect(code.contains("init(_ _7: Bool, label: String)"))
        #expect(code.contains("self._7 = _7"))
        #expect(code.contains("self.label = label"))
        #expect(code.contains("case _7 = 7"))
    }

    @Test(arguments: ["Missing", "NotAFunction"])
    func invalidServiceMethodReferencesAreRejected(reference: String) {
        let interface = CandidInterfaceDefinition(
            namedTypes: ["NotAFunction": .bool],
            service: .init(name: nil, signature: .init([
                .init(name: "call", signatureType: .reference(reference))
            ]))
        )
        #expect {
            try CandidCodeGenerator().generateSwiftCode(for: interface, nameSpace: "Example")
        } throws: { error in
            guard case CandidCodeGeneratorError.invalidFunctionReference = error else { return false }
            return true
        }
    }

    @Test func generatedNamesAvoidExistingUnnamedTypes() throws {
        let interface = CandidInterfaceDefinition(namedTypes: [
            "UnnamedType0": .bool,
            "Z": .record(["child": .record(["flag": .bool])])
        ])
        let context = try CodeGenerationContext(from: interface)
        #expect(context.namedTypes["UnnamedType0"] == .bool)
        #expect(context.namedTypes["UnnamedType1"] == .record(["flag": .bool]))
        #expect(context.namedTypes["Z"] == .record(["child": .named("UnnamedType1")]))
    }

    @Test func duplicateNamesReceiveDistinctSuffixes() throws {
        let interface = CandidInterfaceDefinition([
            .init(name: "Item", type: .bool),
            .init(name: "Item", type: .text),
            .init(name: "Item", type: .natural8)
        ])
        let context = try CodeGenerationContext(from: interface)
        #expect(Set(context.namedTypes.map(\.name)) == ["Item", "Item_0", "Item_1"])
        for type: CandidType in [.bool, .text, .natural8] {
            #expect(context.namedTypes.contains { $0.type == type })
        }
    }

    @Test func reservedServiceTypeIsRenamedInReference() throws {
        let interface = CandidInterfaceDefinition(
            namedTypes: ["Data": .service(.init([]))],
            service: .init(name: "API", signatureReference: "Data")
        )
        let code = try CandidCodeGenerator(.init(generateHeader: false))
            .generateSwiftCode(for: interface, nameSpace: "Example")
        #expect(code.contains("typealias API = C_Data"))
    }

    @Test func reservedFunctionTypeIsRenamedInServiceMethod() throws {
        let interface = CandidInterfaceDefinition(
            namedTypes: ["Data": .function(.init([CandidType](), []))],
            service: .init(name: "API", signature: .init([
                .init(name: "call", signatureType: .reference("Data"))
            ]))
        )
        let context = try CodeGenerationContext(from: interface)
        let service = try #require(context.service)
        guard case .concrete(let methods) = service.type,
              case .reference(let name) = methods.first?.signature else {
            Issue.record("Expected a referenced service method")
            return
        }
        #expect(name == "C_Data")
        #expect(context.namedTypes["C_Data"] == .function(.init([CandidType](), [])))
    }

    @Test func absentFunctionReferenceGeneratesNil() throws {
        let value = CandidValue.function(CandidFunction(signature: .init([CandidType](), []), method: nil))
        let code = try CandidCodeGenerator(.init(generateHeader: false))
            .generateSwiftCode(for: value, valueName: "callback")
        #expect(code == "let callback: ICPCallNoArgsNoResult = nil")
    }
}
