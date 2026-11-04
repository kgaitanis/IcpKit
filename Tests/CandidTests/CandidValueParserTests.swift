//
//  CandidValueParserTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 12.07.24.
//

import Foundation
import Testing
@testable import Candid

struct CandidValueParserTests {
    private let parser = CandidParser()

    @Test func emptyInputThrows() {
        #expect(throws: (any Error).self) { try ByteInputStream(Data()).readNextByte() }
    }

    @Test(arguments: CandidValueParserTestVectors.singleValueTests.indices)
    func `Parse prim value`(_ index: Int) throws {
        let (string, expected) = CandidValueParserTestVectors.singleValueTests[index]
        let parsed = try parser.parseValue(string)
        #expect(parsed == expected, "\(parsed.description) is not equal to \(string)")
    }
    
    @Test(arguments: CandidValueParserTestVectors.failingSingleValues.indices)
    func `Failing prim values`(_ index: Int) {
        let (string, reason) = CandidValueParserTestVectors.failingSingleValues[index]
        #expect(throws: (any Error).self, "'\(string)' should fail because '\(reason)'") { try parser.parseValue(string) }
    }
    
    @Test func `Real world`() throws {
        let realWorld = CandidValueParserTestVectors.realWorldEvm
        let parsed = try parser.parseValue(realWorld)
        guard case .vector(let vector) = parsed else {
            Issue.record("not a vector")
            return
        }
        let first = try #require(vector.values.first)
        #expect(first == .record([
            "cyclesPerCall": .natural64(0),
            "owner": try .principal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
            "hostname": .text("cloudflare-eth.com"),
            "primary": .bool(false),
            "chainId": .natural64(1),
            "cyclesPerMessageByte": .natural64(0),
            "providerId": .natural64(0),
        ]))
        
        let last = try #require(vector.values.last)
        #expect(last == .record([
            "cyclesPerCall": .natural64(0),
            "owner": try .principal("rxqtr-vwnhc-q4tjx-lozjs-u7nxo-2tqsn-cusmy-ip2ke-zy52n-x2ukd-gae"),
            "hostname": .text("optimism-rpc.publicnode.com\n"),
            "primary": .bool(false),
            "chainId": .natural64(10),
            "cyclesPerMessageByte": .natural64(0),
            "providerId": .natural64(21),
        ]))
    }
}

struct CandidValueParserValidationTests {
    @Test(arguments: [
        "65536 : nat16", "4294967296 : nat32", "18446744073709551616 : nat64",
        "32768 : int16", "-32769 : int16", "2147483648 : int32",
        "-2147483649 : int32", "9223372036854775808 : int64", "-9223372036854775809 : int64",
        "true : nat16", "true : nat32", "true : nat64", "true : int16",
        "true : int32", "true : int64", "true : float32", "true : float64", "true : text"
    ])
    func valueAnnotationsRejectOverflowAndWrongTypes(_ input: String) {
        #expect(throws: CandidParserError.self) { try CandidParser().parseValue(input) }
    }
}
