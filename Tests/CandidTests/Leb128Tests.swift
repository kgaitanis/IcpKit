//
//  Leb128Tests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 01.05.23.
//

import Foundation
import Testing
import BigInt
@testable import Candid

struct Leb128Tests {

    // test vectors generated using python leb128 https://pypi.org/project/leb128/
    @Test func `Leb128 encode unsigned`() {
        let testVectors: [(BigUInt, [UInt8])] = [
            (0,[0x00]),
            (127,[0x7f]),
            (128,[0x80, 0x01]),
            (300, [0xac, 0x02]),
            (255, [0xff, 0x01]),
            (624485, [0xe5, 0x8e, 0x26]),
            (18446744073709551615, [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01]),
        ]
        for (value, expected) in testVectors {
            #expect(Leb128.encodeUnsigned(value) == Data(expected))
        }
    }
    
    // test vectors generated using python leb128 https://pypi.org/project/leb128/
    @Test func `Leb128 encode signed`() {
        let testVectors: [(BigInt, [UInt8])] = [
            (0,[0x00]),
            (63,[0x3f]),
            (64,[0xc0, 0x00]),
            (-63,[0x41]),
            (-64,[0x40]),
            (-65,[0xbf, 0x7f]),
            (-128,[0x80, 0x7f]),
            (-129,[0xff, 0x7e]),
            (97, [0xe1, 0x00]),
            (127,[0xff, 0x00]),
            (624485, [0xe5, 0x8e, 0x26]),
            (-123456, [0xc0, 0xbb, 0x78]),
            (-999999999, [0x81, 0xec, 0x94, 0xa3, 0x7c]),
        ]
        for (value, expected) in testVectors {
            #expect(Leb128.encodeSigned(value) == Data(expected))
        }
    }
    
    @Test func `Leb128 decode unsigned`() throws {
        let testVectors: [(BigUInt, [UInt8])] = [
            (0,[0x00]),
            (127,[0x7f]),
            (128,[0x80, 0x01]),
            (300, [0xac, 0x02]),
            (255, [0xff, 0x01]),
            (624485, [0xe5, 0x8e, 0x26]),
            (18446744073709551615, [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01]),
        ]
        for (expected, inputBytes) in testVectors {
            let data = Data(inputBytes)
            let stream = ByteInputStream(data)
            #expect(try Leb128.decodeUnsigned(stream) == expected)
            #expect(!stream.hasBytesAvailable)
        }
    }
    
    @Test func `Leb128 decode signed`() throws {
        let testVectors: [(BigInt, [UInt8])] = [
            (0,[0x00]),
            (63,[0x3f]),
            (64,[0xc0, 0x00]),
            (-63,[0x41]),
            (-64,[0x40]),
            (-65,[0xbf, 0x7f]),
            (-128,[0x80, 0x7f]),
            (-129,[0xff, 0x7e]),
            (97, [0xe1, 0x00]),
            (127,[0xff, 0x00]),
            (624485, [0xe5, 0x8e, 0x26]),
            (-123456, [0xc0, 0xbb, 0x78]),
            (-999999999, [0x81, 0xec, 0x94, 0xa3, 0x7c]),
        ]
        for (expected, inputBytes) in testVectors {
            let data = Data(inputBytes)
            let stream = ByteInputStream(data)
            #expect(try Leb128.decodeSigned(stream) == expected)
            #expect(!stream.hasBytesAvailable)
        }
    }
    
    // TODO: Remove this when Leb encodeSigned works with BigInt
    @Test func `Leb128 encode signed big int`() {
        for i in 0...255 {
            let int = Leb128.encodeSigned(-i)
            let bigInt = Leb128.encodeSigned(BigInt(-i))
            #expect(int == bigInt)
            if int != bigInt {
                print("MISMATCH \(i) --> int: \(int.hex) | bigInt: \(bigInt.hex)")
            }
        }
    }

}

struct Leb128ValidationTests {
    @Test func signedDecodingHandlesTruncationAndNegativeValues() {
        #expect(throws: (any Error).self) {
            let _: Int = try Leb128.decodeSigned(Data([0x80]))
        }
        let signed: Int = try! Leb128.decodeSigned(Data([0xc0, 0xbb, 0x78]))
        #expect(signed == -123456)
    }
}
