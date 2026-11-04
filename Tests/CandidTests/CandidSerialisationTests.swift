//
//  CandidSerialisationTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 28.04.23.
//

import Foundation
import Testing
@testable import Candid

struct CandidSerialisationTests {
    let serialiser = CandidSerialiser()
    let deserialiser = CandidDeserialiser()
    
    @Test(arguments: CandidSerialisationTestVectors.singleValueTestVectors.indices)
    func `Serialise deserialise single values`(_ index: Int) throws {
        let (value, expected) = CandidSerialisationTestVectors.singleValueTestVectors[index]
        let encoded = serialiser.encode(value)
        #expect(encoded == CandidSerialiser.magicBytes + Data(expected), "\(value) --expected \(Data(expected).hex) -- got -- \(encoded.hex)")
        let decoded = try deserialiser.decode(encoded)
        #expect(value == decoded.first)
    }
    
    @Test(arguments: CandidSerialisationTestVectors.multipleValuesTestVectors.indices)
    func `Serialise deserialise multiple values`(_ index: Int) throws {
        let (value, expected) = CandidSerialisationTestVectors.multipleValuesTestVectors[index]
        let encoded = serialiser.encode(value)
        #expect(encoded == CandidSerialiser.magicBytes + Data(expected), "\(value) --expected \(Data(expected).hex) -- got -- \(encoded.hex)")
        let decoded = try deserialiser.decode(encoded)
        #expect(value == decoded)
    }
    
    @Test(arguments: CandidSerialisationTestVectors.realWorldExamples.indices)
    func `Real world examples`(_ index: Int) throws {
        let input = CandidSerialisationTestVectors.realWorldExamples[index]
        let data = try #require(Data.fromHex(input))
        _ = try deserialiser.decode(data)
    }
    
    @Test(arguments: CandidSerialisationTestVectors.recursiveExamples.indices)
    func recursive(_ index: Int) throws {
        let (expected, hex) = CandidSerialisationTestVectors.recursiveExamples[index]
        let data = CandidSerialiser.magicBytes + (try #require(Data.fromHex(hex)))
        let deserialised = try #require(try deserialiser.decode(data).first)
        #expect(deserialised == expected)
    }
    
    @Test func `Dictionary key hash`() {
        let testVectors: [(String, Int)] = [
            ("a", 97),
            ("b", 98),
            ("c", 99),
            ("ab", 21729),
            ("ba", 21951),
            ("ac", 21730),
            ("abcd %§±`~", 1687702841),
            (String(repeating: "abcd", count: 1000), 3277195728),
        ]
        for (string, expectedHash) in testVectors {
            let hashed = CandidKey.candidHash(string)
            #expect(hashed == expectedHash)
        }
    }
    
    @Test func `Function reference real world`() throws {
        // this example contains several function references
        let candidData = Data.fromHex("4449444c196c0597928bda010186dda8bf0a03a4c7a8ce0c7891fb95920d7883f4f4c40f106e026d7b6d046c03dec389dc0405d6a9bbae0a0bc39c99ad0f016c04ba89e5c2047893a6c6900901a78882820a0682f3f3910c0b6e076b05adfaedfb0108ef80e5df020cc2f5d599030dcbd6fda00b0ed5fce8ea0e0f6c05c6fcb60209eaca8a9e0402b98792ea077cdea7f7da0d0acb96dcb40e026c01e0a9b302786e0b6c01d6f68e8001786c02eaca8a9e0402d8a38ca80d096c02fbca0102d8a38ca80d096c04fbca0102c6fcb60209eaca8a9e0402d8a38ca80d096c05fbca0102c6fcb60209eaca8a9e0402d8a38ca80d09cb96dcb40e026d116c03c5b39af80712e2e8ada00878e6a99ef809786a0113011401016c02e2e8ada00878e6a99ef809786b02bc8a0115c5fed201166c0186dda8bf0a036b02b0ad8cd40417b0ad8fcd0c186c02c1a482a6057880d5dbdd05786c0290c6c1960571c498b1b50d78010000010000000000000000000103207750c79b3d0ef35a5ffc3fc1b350d84575ae5f76d763271bb815fe6c6c2350c6102700000000000020cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c102700000000000000844208c55e5f17f9def690c55e5f170120fb34cfdac368b0d0853f8783dfb1776659c6ff3fdee5e9394db050523a5dd6efaa655d0000000000b9625d000000000000")!
        
        #expect(throws: Never.self) { try deserialiser.decode(candidData) }
    }
}

struct CandidSerialisationValidationTests {
    @Test func absentReferencesHaveExplicitWireMarkers() throws {
        let fixtures: [(CandidValue, String)] = [
            (.principal(nil), "4449444c00016800"),
            (.function([CandidType](), []), "4449444c016a000000010000"),
            (.service([]), "4449444c016900010000")
        ]
        for (value, hex) in fixtures {
            let bytes = try #require(Data.fromHex(hex))
            #expect(CandidSerialiser().encode(value) == bytes)
            #expect(try CandidDeserialiser().decode(bytes) == [value])
        }
        #expect(CandidSerialiser().encode(CandidValue?.none) == Data([68, 73, 68, 76, 0, 0]))
    }

    // Hand-authored DIDL fixtures isolate validation from the serializer.
    @Test func malformedWireDataProducesTypedErrors() throws {
        let fixtures: [(String, CandidDeserialisationError)] = [
            ("000000000000", .invalidPrefix),
            ("4449444c000000", .unserialisedBytesLeft),
            ("4449444c00017101ff", .invalidUtf8String),
            ("4449444c017e00", .invalidPrimitive),
            ("4449444c010000", .invalidPrimitive),
            ("4449444c016d6d00", .invalidPrimitive),
            ("4449444c01690101667e00", .invalidTypeReference),
            ("4449444c01690101ff", .invalidUtf8String),
            ("4449444c016a00000001000100", .invalidTypeReference),
            ("4449444c016a000000010001010001ff", .invalidUtf8String),
            ("4449444c00016d", .invalidPrimitive)
        ]
        for (hex, expected) in fixtures {
            let bytes = try #require(Data.fromHex(hex))
            #expect(throws: expected) { try CandidDeserialiser().decode(bytes) }
        }
    }

    @Test func truncatedInputThrowsInsteadOfReadingPastEnd() {
        for bytes in [Data(), Data([68, 73, 68, 76]), Data([68, 73, 68, 76, 0, 1, 126])] {
            #expect(throws: (any Error).self) { try CandidDeserialiser().decode(bytes) }
        }
    }
}
