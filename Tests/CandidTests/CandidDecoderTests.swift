import Foundation
import Testing
@testable import Candid

struct CandidDecoderTests {
    @Test func keyedPrimitiveOverloadsPreserveTypesAndValues() throws {
        let decoded = try CandidDecoder().decode(KeyedPrimitiveRecord.self, from: KeyedPrimitiveRecord.candidValue)
        #expect(decoded.bool == Bool(true))
        #expect(decoded.text == String("hello"))
        #expect(decoded.float == Float(1.5))
        #expect(decoded.double == Double(-2.5))
        #expect(decoded.int == Int(-42))
        #expect(decoded.int8 == Int8.min)
        #expect(decoded.int16 == Int16.min)
        #expect(decoded.int32 == Int32.min)
        #expect(decoded.int64 == Int64.min)
        #expect(decoded.uint == UInt(42))
        #expect(decoded.uint8 == UInt8.max)
        #expect(decoded.uint16 == UInt16.max)
        #expect(decoded.uint32 == UInt32.max)
        #expect(decoded.uint64 == UInt64.max)
    }

    @Test func unkeyedUIntUsesNaturalAndAdvances() throws {
        let decoded = try CandidDecoder().decode(NaturalElement.self, from: .vector([.natural(42)]))
        #expect(decoded.value == 42)
    }

    @Test func missingNestedRecordReportsKeyAndPath() {
        #expect {
            try CandidDecoder().decode(NestedRecord.self, from: .record())
        } throws: { error in
            guard case DecodingError.keyNotFound(let key, let context) = error else { return false }
            return key.stringValue == "value" && context.codingPath.isEmpty
        }
    }

    @Test func codingKeysRejectUnknownRepresentations() {
        #expect(IntCodingKey(stringValue: "12") == nil)
        #expect(Field(intValue: -1) == nil)
        #expect(Field(intValue: CandidKey.candidHash("value")) == .value)
    }

    @Test func explicitPrimitiveContainersPreserveValues() throws {
        // Explicit overloads catch wiring errors that Array's generic decode does not exercise.
        let input: CandidValue = .record([
            "bool": try .vector([.bool(true)]),
            "text": try .vector([.text("hello")]),
            "float": try .vector([.float32(1.5)]),
            "double": try .vector([.float64(-2.5)]),
            "int": try .vector([.integer64(-42)]),
            "int8": try .vector([.integer8(-128)]),
            "int16": try .vector([.integer16(-32768)]),
            "int32": try .vector([.integer32(-2147483648)]),
            "int64": try .vector([.integer64(.min)]),
            "uint8": try .vector([.natural8(255)]),
            "uint16": try .vector([.natural16(65535)]),
            "uint32": try .vector([.natural32(.max)]),
            "uint64": try .vector([.natural64(.max)])
        ])
        let decoded = try CandidDecoder().decode(PrimitiveVectors.self, from: input)
        #expect(decoded.bool == true)
        #expect(decoded.text == "hello")
        #expect(decoded.float == 1.5)
        #expect(decoded.double == -2.5)
        #expect(decoded.int == -42)
        #expect(decoded.int8 == -128)
        #expect(decoded.int16 == -32768)
        #expect(decoded.int32 == -2147483648)
        #expect(decoded.int64 == .min)
        #expect(decoded.uint8 == 255)
        #expect(decoded.uint16 == 65535)
        #expect(decoded.uint32 == .max)
        #expect(decoded.uint64 == .max)
    }

    @Test func nestedContainersPreserveValuesAndAdvance() throws {
        let records = try CandidValue.vector([.record(["value": .text("first")]), .record(["value": .text("second")])])
        let decoded = try CandidDecoder().decode(NestedRecords.self, from: records)
        #expect(decoded.values == ["first", "second"])
        let vectors = try CandidValue.vector([.vector([.natural8(7)]), .vector([.natural8(9)])])
        #expect(try CandidDecoder().decode(NestedVectors.self, from: vectors).values == [7, 9])
    }

    @Test func readingPastEndReportsDataCorruption() throws {
        #expect {
            try CandidDecoder().decode(NestedRecords.self, from: .vector(.record(["value": .text])))
        } throws: { error in
            guard case DecodingError.dataCorrupted(let context) = error else { return false }
            return context.codingPath.last?.intValue == 0
        }
    }

    @Test func missingPrimitiveKeyReportsKeyAndPath() {
        #expect {
            try CandidDecoder().decode(RequiredRecord.self, from: .record())
        } throws: { error in
            guard case DecodingError.keyNotFound(let key, let context) = error else { return false }
            return key.stringValue == "value" && context.codingPath.isEmpty
        }
    }

    @Test func missingGenericKeyReportsKeyAndPath() {
        #expect {
            try CandidDecoder().decode(RequiredArray.self, from: .record())
        } throws: { error in
            guard case DecodingError.keyNotFound(let key, let context) = error else { return false }
            return key.stringValue == "value" && context.codingPath.isEmpty
        }
    }

    @Test func missingNestedVectorReportsKeyAndPath() {
        #expect {
            try CandidDecoder().decode(PrimitiveVectors.self, from: .record())
        } throws: { error in
            guard case DecodingError.keyNotFound(let key, let context) = error else { return false }
            return key.stringValue == "bool" && context.codingPath.isEmpty
        }
    }

    @Test func wrongFieldTypeReportsFieldPath() {
        #expect {
            try CandidDecoder().decode(RequiredRecord.self, from: .record(["value": .bool(true)]))
        } throws: { error in
            guard case DecodingError.typeMismatch(let type, let context) = error else { return false }
            return type == String.self && context.codingPath.map(\.stringValue) == ["value"]
        }
    }

    @Test func rejectsWrongContainerKinds() {
        #expect {
            try CandidDecoder().decode(RequiredRecord.self, from: .text("wrong"))
        } throws: { error in
            guard case DecodingError.dataCorrupted = error else { return false }
            return true
        }
        #expect {
            try CandidDecoder().decode([String].self, from: .bool(false))
        } throws: { error in
            guard case DecodingError.typeMismatch = error else { return false }
            return true
        }
    }

    @Test func nilProbeConsumesNullElement() throws {
        #expect(try CandidDecoder().decode(NullElement.self, from: .vector([.null])).consumed)
    }

    @Test func rejectsFunctionWithoutMethod() {
        let input = CandidValue.function(CandidFunction(signature: .init([CandidType](), []), method: nil))
        #expect {
            try CandidDecoder().decode(FunctionReference.self, from: input)
        } throws: { error in
            guard case EncodingError.invalidValue(_, let context) = error else { return false }
            return context.codingPath.isEmpty
        }
    }

    @Test func rejectsServiceWithoutPrincipal() {
        let input = CandidValue.service(CandidService(principal: nil, signature: .init([])))
        #expect {
            try CandidDecoder().decode(ServiceReference.self, from: input)
        } throws: { error in
            guard case EncodingError.invalidValue(_, let context) = error else { return false }
            return context.codingPath.isEmpty
        }
    }
}

private enum Field: String, CandidCodingKey {
    case value
}

private struct RequiredRecord: Decodable {
    let value: String
}

private struct RequiredArray: Decodable {
    let value: [String]
}

private struct NestedRecords: Decodable {
    let values: [String]

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let first = try container.nestedContainer(keyedBy: Field.self)
        let second = try container.nestedContainer(keyedBy: Field.self)
        values = [try first.decode(String.self, forKey: .value), try second.decode(String.self, forKey: .value)]
        #expect(container.currentIndex == 2)
        #expect(container.isAtEnd)
    }
}

private struct NestedVectors: Decodable {
    let values: [UInt8]

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var first = try container.nestedUnkeyedContainer()
        var second = try container.nestedUnkeyedContainer()
        values = [try first.decode(UInt8.self), try second.decode(UInt8.self)]
        #expect(container.isAtEnd)
        #expect(first.isAtEnd)
        #expect(second.isAtEnd)
    }
}

private struct NullElement: Decodable {
    let consumed: Bool

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let isNil = try container.decodeNil()
        consumed = isNil && container.currentIndex == 1 && container.isAtEnd
    }
}

private struct FunctionReference: CandidFunctionProtocol {
    let canister: CandidPrincipal
    let methodName: String
    let isQuery = true

    init(_ canister: CandidPrincipal, _ method: String) {
        self.canister = canister
        self.methodName = method
    }
}

private struct ServiceReference: CandidServiceProtocol {
    let principal: CandidPrincipal

    init(_ principal: CandidPrincipal) {
        self.principal = principal
    }
}

private struct PrimitiveVectors: Decodable {
    let bool: Bool
    let text: String
    let float: Float
    let double: Double
    let int: Int
    let int8: Int8
    let int16: Int16
    let int32: Int32
    let int64: Int64
    let uint8: UInt8
    let uint16: UInt16
    let uint32: UInt32
    let uint64: UInt64

    private enum CodingKeys: String, CodingKey {
        case bool, text, float, double, int, int8, int16, int32, int64, uint8, uint16, uint32, uint64
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var boolValues = try container.nestedUnkeyedContainer(forKey: .bool)
        bool = try boolValues.decode(Bool.self)
        #expect(boolValues.isAtEnd)
        var textValues = try container.nestedUnkeyedContainer(forKey: .text)
        text = try textValues.decode(String.self)
        #expect(textValues.isAtEnd)
        var floatValues = try container.nestedUnkeyedContainer(forKey: .float)
        float = try floatValues.decode(Float.self)
        #expect(floatValues.isAtEnd)
        var doubleValues = try container.nestedUnkeyedContainer(forKey: .double)
        double = try doubleValues.decode(Double.self)
        #expect(doubleValues.isAtEnd)
        var intValues = try container.nestedUnkeyedContainer(forKey: .int)
        int = try intValues.decode(Int.self)
        #expect(intValues.isAtEnd)
        var int8Values = try container.nestedUnkeyedContainer(forKey: .int8)
        int8 = try int8Values.decode(Int8.self)
        #expect(int8Values.isAtEnd)
        var int16Values = try container.nestedUnkeyedContainer(forKey: .int16)
        int16 = try int16Values.decode(Int16.self)
        #expect(int16Values.isAtEnd)
        var int32Values = try container.nestedUnkeyedContainer(forKey: .int32)
        int32 = try int32Values.decode(Int32.self)
        #expect(int32Values.isAtEnd)
        var int64Values = try container.nestedUnkeyedContainer(forKey: .int64)
        int64 = try int64Values.decode(Int64.self)
        #expect(int64Values.isAtEnd)
        var uint8Values = try container.nestedUnkeyedContainer(forKey: .uint8)
        uint8 = try uint8Values.decode(UInt8.self)
        #expect(uint8Values.isAtEnd)
        var uint16Values = try container.nestedUnkeyedContainer(forKey: .uint16)
        uint16 = try uint16Values.decode(UInt16.self)
        #expect(uint16Values.isAtEnd)
        var uint32Values = try container.nestedUnkeyedContainer(forKey: .uint32)
        uint32 = try uint32Values.decode(UInt32.self)
        #expect(uint32Values.isAtEnd)
        var uint64Values = try container.nestedUnkeyedContainer(forKey: .uint64)
        uint64 = try uint64Values.decode(UInt64.self)
        #expect(uint64Values.isAtEnd)
    }
}

private struct NestedRecord: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Field.self)
        _ = try container.nestedContainer(keyedBy: Field.self, forKey: .value)
    }
}

private struct NaturalElement: Decodable {
    let value: UInt

    init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decode(UInt.self)
        #expect(container.currentIndex == 1)
        #expect(container.isAtEnd)
    }
}
