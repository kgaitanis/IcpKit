//
//  CandidEncoderTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 18.07.24.
//

import Testing
import BigInt
import Candid
import Foundation

struct CandidEncoderTests {
    @Test func keyedPrimitiveOverloadsPreserveTypesAndValues() throws {
        #expect(try CandidEncoder().encode(KeyedPrimitiveRecord()) == KeyedPrimitiveRecord.candidValue)
    }

    @Test func encoding() throws {
        let vectors = commonTestVectors.map { ($0.0, $0.1) } + encodingTestVectors
        for (input, expected) in vectors {
            let encoded = try CandidEncoder().encode(input)
            #expect(encoded == expected, "\(String(describing: input))")
        }
        for (input, errorType) in failingEncodingTestVectors {
            #expect {
                try CandidEncoder().encode(input)
            } throws: { error in
                type(of: error) == errorType
            }
        }
    }
    
    @Test func decoding() throws {
        let vectors = commonTestVectors + decodingTestVectors
        for (expected, input, type) in vectors {
            do {
                let decoded = try CandidDecoder().decode(type, from: input)
                #expect(String(describing: decoded) == String(describing: expected), "\(input) decoded to \(decoded) but was expecting \(expected)")
            } catch (let error) {
                Issue.record("\(input) failed to decode to \(expected). Error: \(error)")
            }
        }
        for (input, failingType, reason) in failingDecodingTestVectors {
            #expect(throws: DecodingError.self, "\(reason)", performing: { try CandidDecoder().decode(failingType, from: input) })
        }
    }
}

nonisolated(unsafe) private let commonTestVectors: [(any Codable, CandidValue, any Decodable.Type)] = [
    (true, .bool(true), Bool.self),
    (false, .bool(false), Bool.self),
    ("text", .text("text"), String.self),
    (UInt8(1), .natural8(1), UInt8.self),
    (UInt16(2), .natural16(2), UInt16.self),
    (UInt32(3), .natural32(3), UInt32.self),
    (UInt64(4), .natural64(4), UInt64.self),
    (UInt(5), .natural64(5), UInt.self),
    (BigUInt(6), .natural(6), BigUInt.self),
    (Int8(-1), .integer8(-1), Int8.self),
    (Int16(-2), .integer16(-2), Int16.self),
    (Int32(-3), .integer32(-3), Int32.self),
    (Int64(-4), .integer64(-4), Int64.self),
    (Int(-5), .integer64(-5), Int.self),
    (BigInt(-6), .integer(-6), BigInt.self),
    (Float(1.5), .float32(1.5), Float.self),
    (Double(1.5), .float64(1.5), Double.self),
    (Data([]), .blob(Data()), Data.self),
    (Data([1,2,3,4]), .blob(Data([1,2,3,4])), Data.self),
    (Data?.some(Data([1])), .option(.blob(Data([1]))), Data?.self),
    
    (Optional(8), .option(.integer64(8)), Int?.self),
    (Bool?.none, .option(.bool), Bool?.self),
    (String?.none, .option(.text), String?.self),
    (Bool?(true), .option(.bool(true)), Bool?.self),
    (Bool??(true), .option(.option(.bool(true))), Bool??.self),
    (Optional(Bool?.none), .option(CandidValue.option(.bool)), Bool??.self),
    (Data?.none, .option(.blob), Data?.self),
    (Data?.some(Data([1,2])), .option(.blob(Data([1,2]))), Data?.self),
    (UInt8?.none, .option(.natural8), UInt8?.self),
    (UInt16?.none, .option(.natural16), UInt16?.self),
    (UInt32?.none, .option(.natural32), UInt32?.self),
    (UInt64?.none, .option(.natural64), UInt64?.self),
    (UInt?.none, .option(.natural64), UInt?.self),
    (BigUInt?.none, .option(.natural), BigUInt?.self),
    (Int8?.none, .option(.integer8), Int8?.self),
    (Int16?.none, .option(.integer16), Int16?.self),
    (Int32?.none, .option(.integer32), Int32?.self),
    (Int64?.none, .option(.integer64), Int64?.self),
    (Int?.none, .option(.integer64), Int?.self),
    (BigInt?.none, .option(.integer), BigInt?.self),
    (Float?.none, .option(.float32), Float?.self),
    (Double?.none, .option(.float64), Double?.self),
    (Optional(Optional(8)), .option(.option(.integer64(8))), Int??.self),
    (Optional(Int?.none), .option(CandidValue.option(.integer64)), Int??.self),
    (Int??.none, .option(CandidType.option(.integer64)), Int??.self),
    (Bool??.none, .option(CandidType.option(.bool)), Bool??.self),
    
    ([String](), .vector(.text), [String].self),
    ([Int](), .vector(.integer64), [Int].self),
    ([0,1], try! .vector([.integer64(0), .integer64(1)]), [Int].self),
    ([0,nil,2], try! .vector([.option(.integer64(0)), .option(.integer64), .option(.integer64(2))]), [Int?].self),
    ([[0,nil], []], try! .vector([.vector([.option(.integer64(0)), .option(.integer64)]), .vector(.option(.integer64))]), [[Int?]].self),
    
    (["a": 0], .record(["a": .integer64(0)]), [String: Int].self),
    // this test works but the produced dictionary has random order
    //(["b": UInt8(8), "a": 0], .record(["a": .natural8(0), "b": .natural8(8)]), [String: UInt8].self),
    
    (TestRecord(a: 1, b: 2), .record(["a": .natural8(1), "b": .integer64(2)]), TestRecord.self),
    (TestRecord2(a: [1, nil]), .record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])]), TestRecord2.self),
    (TestRecord3(record: TestRecord(a: 1, b: 2), records2: [TestRecord2(a: [1, nil])]), .record([
        "record":  .record(["a": .natural8(1), "b": .integer64(2)]),
        "records2": try! .vector([.record(["a": try! .vector([.option(.natural8(1)), .option(.natural8)])])]),
    ]), TestRecord3.self),
    (TestUnnamedRecord(anyName: "text", _1: 2), .record([.text("text"), .option(.natural8(2))]), TestUnnamedRecord.self),
    (TestDataRecord2(data: Data([1])), .record(["data": .option(.blob(Data([1])))]), TestDataRecord2.self),
    (TestDataRecord3(data: Data([1])), .record(["data": .option(.option(.blob(Data([1]))))]), TestDataRecord3.self),
    (TestDataRecord(vector: [.init(data: Data([1]))]), .record(["vector": try! .vector([.record(["data": .option(.blob(Data([1])))])])]), TestDataRecord.self),
    (TestRecord(a: 1, b: 2), .record([97: .natural8(1), 98: .integer64(2)]), TestRecord.self),
    (TestDataRecord2(data: nil), .record(["data": .option(.blob)]), TestDataRecord2.self),
    (TestRecord?.none, .option(CandidType.empty), TestRecord?.self),    // can not detect type of nil structs
    (PassThroughCandidValue(candid: .option(CandidType.reserved)), .record(["candid": .option(CandidType.reserved)]), PassThroughCandidValue.self),
    
    (TestEnum.a, .variant(.init("a", .null)), TestEnum.self),
    (TestEnum.b(2), .variant(.init("b", .option(.natural8(2)))), TestEnum.self),
    (TestEnum.c(.a), .variant(.init("c", .variant(.init("a")))), TestEnum.self),
    (TestEnum.d([1,2]), .variant(.init("d", try! .vector([.natural8(1), .natural8(2)]))), TestEnum.self),
    (TestEnum.e(a: 1, b: 2), .variant(.init("e", .record(["a":.option(.natural8(1)), "b": .natural16(2)]))), TestEnum.self),
    (TestEnum.e(a: 1, b: 2), .variant(.init(101, .record([97:.option(.natural8(1)), 98: .natural16(2)]))), TestEnum.self),
    (TestEnum.f(1, 2), .variant(.init("f", .record([0: .option(.natural8(1)), 1: .natural16(2)]))), TestEnum.self),
    (TestEnum.g(SingleValueRecord(value: 2)), .variant(.init("g", .record(["value": .integer8(2)]))), TestEnum.self),
    (TestEnum.h(a: 2), .variant(.init("h", .record(["a": .option(.natural8(2))]))), TestEnum.self),
    
    (CandidPrincipal("aaaaa-aa"), try! .principal("aaaaa-aa"), CandidPrincipal.self),
    
    (try! TestFunction("aaaaa-aa", "foo"), .function(CandidFunction(signature: .init([CandidType](), []), principal: CandidPrincipal("aaaaa-aa"), methodName: "foo")), TestFunction.self),
    (try! TestService("aaaaa-aa"), try! .service("aaaaa-aa"), TestService.self),
]

// these cases only work when decoding from a candidvalue
nonisolated(unsafe) private let decodingTestVectors: [(any Codable, CandidValue, any Decodable.Type)] = [
    (Bool?.none, .null, Bool?.self),
    (Bool?.none, .empty, Bool?.self),
    (Bool?.none, .reserved, Bool?.self),
    (Bool?.none, .option(CandidType.empty), Bool?.self),
    (Bool?.none, .option(CandidValue.empty), Bool?.self),
    (Bool?.none, .option(CandidValue.null), Bool?.self),
    (Bool?.none, .option(CandidType.null), Bool?.self),
    (Bool?.none, .option(CandidValue.reserved), Bool?.self),
    (Bool?.none, .option(CandidType.reserved), Bool?.self),
    (Data([1,2]), try! .vector([.natural8(1), .natural8(2)]), Data.self),       // vec nat8 to Data conversion
    (TestRecursiveRecord(a: []), .record(["a": .vector(.record())]), TestRecursiveRecord.self),
    (TestRecord?.none, .option(.record(["a": .natural8, "b":.integer64])), TestRecord?.self),   // nil records can detect type correct only on decoding
    (TestDataRecord2(data: nil), .record(), TestDataRecord2.self),  // missing optional values
    (TestEnum.b(nil), .variant(CandidKeyedValue("b")), TestEnum.self),  // missing optional values
    (TestEnum.e(a: nil, b: 1), .variant(CandidKeyedValue("e", .record(["b": .natural16(1)]))), TestEnum.self),  // missing optional values
]

nonisolated(unsafe) private let failingDecodingTestVectors: [(CandidValue, any Decodable.Type, String)] = [
    (.integer8(-1), UInt8.self, "negative number can not convert to unsigned"),
]

// tese cases only work when encoding to a candidvalue
nonisolated(unsafe) private let encodingTestVectors: [(any Encodable, CandidValue)] = [
    //(TestRecord?.none, .option(.record(["a": .natural8, "b":.integer64]))), // returns opt empty
    (CandidFunction(signature: .init([CandidType](), []), method: nil), .function(CandidFunction(signature: .init([CandidType](), []), method: nil))),
    (CandidService(principal: nil, signature: .init([])), .service(CandidService(principal: nil, signature: .init([])))),
    (["b": UInt8(8), "a": 0], .record(["a": .natural8(0), "b": .natural8(8)])),
    (TestEnum.b(nil), .variant(.init("b", .option(.natural8)))),
    (TestEnum.e(a: nil, b: 2), .variant(.init("e", .record(["a": .option(.natural8), "b": .natural16(2)])))),
    (TestEnum.h(a: nil), .variant(.init("h", .record(["a": .option(.natural8)])))),

    // Explicit overloads: Array's generic encoding does not exercise these.
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(true)
    }, try! .vector([.bool(true)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode("text")
    }, try! .vector([.text("text")])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Float(1.5))
    }, try! .vector([.float32(1.5)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Double(1.5))
    }, try! .vector([.float64(1.5)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Int(-5))
    }, try! .vector([.integer64(-5)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Int8(-1))
    }, try! .vector([.integer8(-1)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Int16(-2))
    }, try! .vector([.integer16(-2)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Int32(-3))
    }, try! .vector([.integer32(-3)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(Int64(-4))
    }, try! .vector([.integer64(-4)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(UInt(5))
    }, try! .vector([.natural64(5)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(UInt8(1))
    }, try! .vector([.natural8(1)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(UInt16(2))
    }, try! .vector([.natural16(2)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(UInt32(3))
    }, try! .vector([.natural32(3)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        try container.encode(UInt64(4))
    }, try! .vector([.natural64(4)])),
    (CustomEncoding { encoder in
        var container = encoder.singleValueContainer()
        try container.encode(TestRecord(a: 1, b: 2))
    }, .record(["a": .natural8(1), "b": .integer64(2)])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        var nested = container.nestedContainer(keyedBy: TestRecordKey.self)
        try nested.encode(UInt8(1), forKey: .a)
    }, try! .vector([.record(["a": .natural8(1)])])),
    (CustomEncoding { encoder in
        var container = encoder.unkeyedContainer()
        var nested = container.nestedUnkeyedContainer()
        try nested.encode(UInt8(1))
    }, try! .vector([.vector([.natural8(1)])])),
    (CustomEncoding { encoder in
        var container = encoder.container(keyedBy: TestRecordKey.self)
        var nested = container.nestedUnkeyedContainer(forKey: .a)
        try nested.encode(UInt8(1))
    }, .record(["a": try! .vector([.natural8(1)])])),
]

nonisolated(unsafe) private let failingEncodingTestVectors: [(any Encodable, any Error.Type)] = [
    (TestRawEnum.a, EncodingError.self),
    (TestMalformedEnum.empty, CandidEncoderError.self),
    (TestMalformedEnum.multiple, CandidEncoderError.self),
    (TestMalformedEnum.nonRecord, CandidEncoderError.self),
]

private enum TestRawEnum: String, Encodable {
    case a
}

// Enum encoding requires exactly one case key containing an associated-value record.
private enum TestMalformedEnum: Encodable {
    case empty
    case multiple
    case nonRecord

    private enum CodingKeys: String, CodingKey {
        case a
        case b
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .empty:
            break
        case .multiple:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .a)
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .b)
        case .nonRecord:
            try container.encode(true, forKey: .a)
        }
    }
}

// Allows explicit container operations to use the same input/expected-value list.
private struct CustomEncoding: Encodable {
    let encodeValue: (any Encoder) throws -> Void

    init(_ encodeValue: @escaping (any Encoder) throws -> Void) {
        self.encodeValue = encodeValue
    }

    func encode(to encoder: any Encoder) throws {
        try encodeValue(encoder)
    }
}

private enum TestRecordKey: String, CodingKey {
    case a
}

private struct TestRecord: Codable {
    let a: UInt8
    let b: Int
}

private struct TestRecord2: Codable {
    let a: [UInt8?]
}

private struct TestRecord3: Codable {
    let record: TestRecord
    let records2: [TestRecord2]
}

private struct TestUnnamedRecord: Codable {
    let anyName: String
    let _1: UInt8?
    
    enum CodingKeys: Int, CodingKey {
        case anyName
        case _1
    }
}

private struct TestRecursiveRecord: Codable {
    let a: [TestRecursiveRecord]
}

private struct TestDataRecord: Codable {
    let vector: [TestDataRecord2]
}

private struct TestDataRecord2: Codable {
    let data: Data?
}

private struct TestDataRecord3: Codable {
    let data: Data??
}

private indirect enum TestEnum: Codable {
    case a
    case b(UInt8?)
    case c(TestEnum)
    case d([UInt8])
    case e(a: UInt8?, b: UInt16)
    case f(UInt8?, UInt16)
    case g(SingleValueRecord)
    case h(a: UInt8?)
    
    enum CodingKeys: String, CandidCodingKey {
        case a
        case b
        case c
        case d
        case e
        case f
        case g
        case h
    }
    
    enum ECodingKeys: String, CandidCodingKey {
        case a
        case b
    }
}

private struct SingleValueRecord: Codable {
    let value: Int8
}

private struct PassThroughCandidValue: Codable {
    let candid: CandidValue
}

private struct TestFunction: CandidFunctionProtocol {
    let canister: Candid.CandidPrincipal
    let methodName: String
    var isQuery: Bool = true
    
    init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.methodName = method
    }
}

private struct TestService: CandidServiceProtocol {
    let principal: CandidPrincipal
    
    init(_ principal: CandidPrincipal) {
        self.principal = principal
    }
}

// Shared by encoder and decoder tests so their primitive fixture stays consistent.
struct KeyedPrimitiveRecord: Codable {
    static let candidValue: CandidValue = .record([
        "bool": .bool(true),
        "text": .text("hello"),
        "float": .float32(1.5),
        "double": .float64(-2.5),
        "int": .integer64(-42),
        "int8": .integer8(.min),
        "int16": .integer16(.min),
        "int32": .integer32(.min),
        "int64": .integer64(.min),
        "uint": .natural64(42),
        "uint8": .natural8(.max),
        "uint16": .natural16(.max),
        "uint32": .natural32(.max),
        "uint64": .natural64(.max)
    ])

    var bool: Bool = true
    var text: String = "hello"
    var float: Float = 1.5
    var double: Double = -2.5
    var int: Int = -42
    var int8: Int8 = .min
    var int16: Int16 = .min
    var int32: Int32 = .min
    var int64: Int64 = .min
    var uint: UInt = 42
    var uint8: UInt8 = .max
    var uint16: UInt16 = .max
    var uint32: UInt32 = .max
    var uint64: UInt64 = .max

    init() {}

    private enum CodingKeys: String, CodingKey {
        case bool, text, float, double, int, int8, int16, int32, int64, uint, uint8, uint16, uint32, uint64
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bool, forKey: .bool)
        try container.encode(text, forKey: .text)
        try container.encode(float, forKey: .float)
        try container.encode(double, forKey: .double)
        try container.encode(int, forKey: .int)
        try container.encode(int8, forKey: .int8)
        try container.encode(int16, forKey: .int16)
        try container.encode(int32, forKey: .int32)
        try container.encode(int64, forKey: .int64)
        try container.encode(uint, forKey: .uint)
        try container.encode(uint8, forKey: .uint8)
        try container.encode(uint16, forKey: .uint16)
        try container.encode(uint32, forKey: .uint32)
        try container.encode(uint64, forKey: .uint64)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bool = try container.decode(Bool.self, forKey: .bool)
        text = try container.decode(String.self, forKey: .text)
        float = try container.decode(Float.self, forKey: .float)
        double = try container.decode(Double.self, forKey: .double)
        int = try container.decode(Int.self, forKey: .int)
        int8 = try container.decode(Int8.self, forKey: .int8)
        int16 = try container.decode(Int16.self, forKey: .int16)
        int32 = try container.decode(Int32.self, forKey: .int32)
        int64 = try container.decode(Int64.self, forKey: .int64)
        uint = try container.decode(UInt.self, forKey: .uint)
        uint8 = try container.decode(UInt8.self, forKey: .uint8)
        uint16 = try container.decode(UInt16.self, forKey: .uint16)
        uint32 = try container.decode(UInt32.self, forKey: .uint32)
        uint64 = try container.decode(UInt64.self, forKey: .uint64)
    }
}
