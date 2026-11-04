//
//  CandidParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.06.24.
//

import Foundation
import Testing
@testable import Candid

struct CandidTypeParserTests {
    let parser = CandidParser()
    
    @Test(arguments: CandidTypeParserTestVectors.passingSingleTypes.indices)
    func `Parse single types`(_ index: Int) throws {
        let (input, candidType) = CandidTypeParserTestVectors.passingSingleTypes[index]
        #expect(try parser.parseSingleType(input) == candidType, "Failed \(input)\nNot equal to \(candidType.syntax)")
    }
    
    @Test(arguments: CandidTypeParserTestVectors.comments.indices)
    func `Parse comments`(_ index: Int) throws {
        let (input) = CandidTypeParserTestVectors.comments[index]
        let stream = try CandidParserStream(string: input)
        var foundComments: [String] = []
        while stream.hasNext {
            let token = try stream.takeNext()
            if case .comment(let comment, _) = token {
                foundComments.append(comment)
            }
        }
        #expect(foundComments.isEmpty)
    }
    
    @Test(arguments: CandidTypeParserTestVectors.functionArgumentNames.indices)
    func `Parse function argument names`(_ index: Int) throws {
        let (input, candidType, argNames, resNames) = CandidTypeParserTestVectors.functionArgumentNames[index]
        let parsed = try parser.parseSingleType(input)
        #expect(parsed == candidType, "\(input)\nNot equal to \(candidType.syntax)")
        guard case .function(let signature) = parsed else {
            Issue.record("not a function")
            return
        }
        #expect(signature.arguments.map { $0.name } == argNames)
        #expect(signature.results.map { $0.name } == resNames)
    }
    
    @Test(arguments: CandidTypeParserTestVectors.failingSingleTypes.indices)
    func `Parse failing single type`(_ index: Int) throws {
        let input = CandidTypeParserTestVectors.failingSingleTypes[index]
        #expect(throws: (any Error).self, "\(input)") { try parser.parseSingleType(input) }
    }
    
    @Test(arguments: CandidTypeParserTestVectors.didFiles.indices)
    func `Did files`(_ index: Int) async throws {
        let (did, namedTypes, service) = CandidTypeParserTestVectors.didFiles[index]
        let interface = try await parser.parseInterfaceDescription(did)
        #expect(interface.namedTypes == CandidInterfaceDefinition(namedTypes: namedTypes).namedTypes)
        #expect(interface.service == service)
        #expect(interface.isResolved())
    }
    
    @Test(arguments: CandidTypeParserTestVectors.originalStringDid.indices)
    func `Original string`(_ index: Int) async throws {
        let (did, originalStrings) = CandidTypeParserTestVectors.originalStringDid[index]
        let interface = try await parser.parseInterfaceDescription(did)
        for namedType in interface.namedTypes {
            #expect(namedType.originalDefinition == originalStrings[namedType.name])
        }
    }
    
    @Test(arguments: CandidTypeParserTestVectors.unresolvedDidFiles.indices)
    func `Unresolved did files`(_ index: Int) async throws {
        let did = CandidTypeParserTestVectors.unresolvedDidFiles[index]
        let interface = try await parser.parseInterfaceDescription(did)
        #expect(!interface.isResolved(), "\(did)")
    }
    
    @Test(arguments: CandidTypeParserTestVectors.failingDidFiles.indices)
    func `Failing did files`(_ index: Int) async throws {
        let did = CandidTypeParserTestVectors.failingDidFiles[index]
        await #expect(throws: (any Error).self) {
            _ = try await parser.parseInterfaceDescription(did)
        }
    }
    
    @Test(arguments: CandidTypeParserTestVectors.importedFiles.indices)
    func imports(_ index: Int) async throws {
        let (main, files, types, service) = CandidTypeParserTestVectors.importedFiles[index]
        let provider = MockProvider(main, files)
        let interface = try await parser.parseInterfaceDescription(provider)
        #expect(interface.namedTypes == CandidInterfaceDefinition(namedTypes: types).namedTypes)
        #expect(interface.service == service)
        #expect(interface.isResolved())
    }
    
    @Test(arguments: CandidTypeParserTestVectors.failingImportedFiles.indices)
    func `Failing imports`(_ index: Int) async throws {
        let (main, files) = CandidTypeParserTestVectors.failingImportedFiles[index]
        let provider = MockProvider(main, files)
        await #expect(throws: (any Error).self) {
            _ = try await parser.parseInterfaceDescription(provider)
        }
    }
    
    @Test(arguments: CandidTypeParserTestVectors.realWorldExamples.indices)
    func `Real world examples`(_ index: Int) async throws {
        let (source, nTypes, nMethods) = CandidTypeParserTestVectors.realWorldExamples[index]
        let service = try await parser.parseInterfaceDescription(source)
        #expect(service.namedTypes.count == nTypes)
        guard case .concrete(let serviceSig) = service.service?.signature else {
            Issue.record("no concrete service")
            return
        }
        #expect(serviceSig.methods.count == nMethods)
    }
}

private class MockProvider: CandidInterfaceDefinitionProvider {
    let main: String
    let files: [String: String]
    init(_ main: String, _ files: [String : String]) {
        self.main = main
        self.files = files
    }
    
    func readMain() async throws -> String { main }
    
    func read(contentsOf file: String) async throws -> String {
        guard let contents = files[file] else { throw CandidParserError.unresolvedImport(file) }
        return contents
    }
}

struct CandidTypeParserValidationTests {
    @Test func fileProviderResolvesImportsRelativeToMainFile() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let nested = directory.appendingPathComponent("interfaces")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let main = "import \"types.did\"; service: { lookup: () -> (Result) query; };"
        let types = "type Result = record { answer: bool };"
        try main.write(to: nested.appendingPathComponent("main.did"), atomically: true, encoding: .utf8)
        try types.write(to: nested.appendingPathComponent("types.did"), atomically: true, encoding: .utf8)
        let provider = FileCandidInterfaceDefinitionProvider(workingPath: directory.path, mainFile: "interfaces/main.did")
        #expect(try await provider.readMain() == main)
        #expect(try await provider.read(contentsOf: "types.did") == types)
        let interface = try await CandidParser().parseInterfaceDescription(provider)
        #expect(interface.namedTypes["Result"] == .record(["answer": .bool]))
        #expect(interface.isResolved())
        await #expect(throws: CocoaError.self) { try await provider.read(contentsOf: "missing.did") }
        let missing = FileCandidInterfaceDefinitionProvider(workingPath: directory.path, mainFile: "missing.did")
        await #expect(throws: CocoaError.self) { try await missing.readMain() }
    }

    @Test func stringProviderReportsUnresolvedImports() async {
        await #expect(throws: CandidParserError.self) {
            try await CandidParser().parseInterfaceDescription("import \"missing.did\";")
        }
    }

    @Test func interfaceResolutionRejectsNonFunctionMethodReferences() {
        let definition = CandidInterfaceDefinition(
            namedTypes: ["NotAFunction": .bool],
            service: .init(name: nil, signature: .init([
                .init(name: "f", signatureType: .reference("NotAFunction"))
            ]))
        )
        #expect(!definition.isResolved())
        #expect(definition.removeService().service == nil)
        #expect(definition.removeService().namedTypes == definition.namedTypes)
        #expect(definition.namedTypes.replacing("missing", with: .init(name: "new", type: .text)) == definition.namedTypes)
    }
}
