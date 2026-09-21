//
//  MontgomeryFpTests.swift
//
//  Created by Konstantinos Gaitanis on 20.09.26.
//

import BigInt
@testable import IcpKit
import XCTest

final class MontgomeryFpTests: XCTestCase {
    private let modulus = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab", radix: 16)!

    func testMontgomeryFpConvertsCanonicalValues() throws {
        let values = sampleValues()

        for value in values {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: value))
            XCTAssertEqual(bigInt(from: fieldElement.canonicalLimbs), value)
        }
    }

    func testMontgomeryFpConvertsCanonicalBytes() throws {
        for value in sampleValues() {
            let fieldElement = try MontgomeryFp(canonicalBytes: bytes(from: value))
            XCTAssertEqual(fieldElement.canonicalBytes, bytes(from: value))
        }
    }

    func testMontgomeryFpReducesWideBytes() throws {
        let values = sampleValues() + [
            modulus,
            modulus + 1,
            (modulus * modulus) - 1,
            BigInt("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", radix: 16)!,
        ]

        for value in values {
            let fieldElement = MontgomeryFp(reducingWideBytes: wideBytes(from: value))
            XCTAssertEqual(bigInt(from: fieldElement.canonicalLimbs), value % modulus)
        }
    }

    func testMontgomeryFpProvidesConstantValues() throws {
        XCTAssertEqual(bigInt(from: MontgomeryFp.zero.canonicalLimbs), 0)
        XCTAssertEqual(bigInt(from: MontgomeryFp.one.canonicalLimbs), 1)
    }

    func testMontgomeryFpIdentifiesLexicographicallyLargestValues() throws {
        let halfModulus = (modulus - 1) / 2
        let cases: [(BigInt, Bool)] = [
            (0, false),
            (1, false),
            (halfModulus, false),
            (halfModulus + 1, true),
            (modulus - 1, true),
        ]

        for (value, expected) in cases {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: value))
            XCTAssertEqual(fieldElement.isLexicographicallyLargest, expected)
        }
    }

    func testMontgomeryFpAddsAndSubtracts() throws {
        let pairs = samplePairs()

        for (lhs, rhs) in pairs {
            let lhsElement = MontgomeryFp(canonicalLimbs: limbs(from: lhs))
            let rhsElement = MontgomeryFp(canonicalLimbs: limbs(from: rhs))

            XCTAssertEqual(
                bigInt(from: (lhsElement + rhsElement).canonicalLimbs),
                (lhs + rhs) % modulus
            )
            XCTAssertEqual(
                bigInt(from: (lhsElement - rhsElement).canonicalLimbs),
                mod(lhs - rhs)
            )
        }
    }

    func testMontgomeryFpNegates() throws {
        for value in sampleValues() {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: value))
            XCTAssertEqual(
                bigInt(from: fieldElement.negated().canonicalLimbs),
                value == 0 ? 0 : modulus - value
            )
        }
    }

    func testMontgomeryFpMultipliesBySmallScalarsAndDividesByTwo() throws {
        for value in sampleValues() {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: value))

            XCTAssertEqual(
                bigInt(from: fieldElement.multiplied(bySmall: 7).canonicalLimbs),
                (value * 7) % modulus
            )
            XCTAssertEqual(
                bigInt(from: fieldElement.dividedBy2().canonicalLimbs),
                (value & 1) == 0 ? value / 2 : (value + modulus) / 2
            )
        }
    }

    func testMontgomeryFpMultipliesAndSquares() throws {
        let pairs = samplePairs()

        for (lhs, rhs) in pairs {
            let lhsElement = MontgomeryFp(canonicalLimbs: limbs(from: lhs))
            let rhsElement = MontgomeryFp(canonicalLimbs: limbs(from: rhs))

            XCTAssertEqual(
                bigInt(from: (lhsElement * rhsElement).canonicalLimbs),
                (lhs * rhs) % modulus
            )
            XCTAssertEqual(
                bigInt(from: lhsElement.squared().canonicalLimbs),
                (lhs * lhs) % modulus
            )
        }
    }

    func testMontgomeryFpExponentiates() throws {
        let cases: [(BigInt, UInt64)] = [
            (0, 0),
            (0, 5),
            (1, 0),
            (2, 10),
            (sampleValues()[5], 17),
            (sampleValues()[6], 255),
        ]

        for (base, exponent) in cases {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: base))
            XCTAssertEqual(
                bigInt(from: fieldElement.pow(exponent: exponent).canonicalLimbs),
                try powMod(num: base, power: BigInt(exponent), modulo: modulus)
            )
        }
    }

    func testMontgomeryFpInvertsAndDivides() throws {
        let nonZeroValues = sampleValues().filter { $0 != 0 }

        for value in nonZeroValues {
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: value))
            XCTAssertEqual(
                bigInt(from: (try fieldElement.inverted()).canonicalLimbs),
                try invert(number: value, modulo: modulus)
            )
            XCTAssertEqual(
                bigInt(from: (try fieldElement / fieldElement).canonicalLimbs),
                1
            )
        }
    }

    func testMontgomeryFpComputesSquareRoots() throws {
        let squareRoots = [0, 1, 2, 5, sampleValues()[5], sampleValues()[6]]

        for root in squareRoots {
            let squared = (root * root) % modulus
            let fieldElement = MontgomeryFp(canonicalLimbs: limbs(from: squared))
            let actualRoot = try XCTUnwrap(fieldElement.sqrt())
            let actualValue = bigInt(from: actualRoot.canonicalLimbs)
            XCTAssertTrue(actualValue == root || actualValue == modulus - root)
        }

        let nonResidue = BigInt(5)
        XCTAssertNil(MontgomeryFp(canonicalLimbs: limbs(from: nonResidue)).sqrt())
    }

    func testFpCompatibilityUsesMontgomeryArithmetic() throws {
        let lhsValue = sampleValues()[5]
        let rhsValue = sampleValues()[6]
        let lhs = Fp(reducing: lhsValue)
        let rhs = Fp(reducing: rhsValue)

        XCTAssertEqual(lhs + rhs, Fp(reducing: mod(lhsValue + rhsValue)))
        XCTAssertEqual(lhs - rhs, Fp(reducing: mod(lhsValue - rhsValue)))
        XCTAssertEqual(lhs * rhs, Fp(reducing: mod(lhsValue * rhsValue)))
        let expectedDividedByElement = mod(lhsValue * (try invert(number: rhsValue, modulo: modulus)))
        XCTAssertEqual(try lhs / rhs, Fp(reducing: expectedDividedByElement))
        XCTAssertEqual(lhs * 7, Fp(reducing: mod(lhsValue * 7)))
        let expectedDividedByScalar = mod(lhsValue * (try invert(number: 7, modulo: modulus)))
        XCTAssertEqual(try lhs / 7, Fp(reducing: expectedDividedByScalar))
        XCTAssertEqual(try lhs.pow(exponent: 17), Fp(reducing: try powMod(num: lhsValue, power: 17, modulo: modulus)))
    }

    private func sampleValues() -> [BigInt] {
        [
            0,
            1,
            2,
            modulus - 2,
            modulus - 1,
            BigInt("12523d27d2de2b6f8c44f5aa123456789abcdef0fedcba9876543210", radix: 16)!,
            BigInt("18c3b56a77f871a3e8f2518c6fd1b1979d8e5d01082b341ccdd56f2a72be9bfe1234567890abcdef1234567890abcdef", radix: 16)!,
        ]
    }

    private func samplePairs() -> [(BigInt, BigInt)] {
        let values = sampleValues()
        return [
            (values[0], values[1]),
            (values[1], values[2]),
            (values[3], values[4]),
            (values[5], values[6]),
            (values[6], values[3]),
            (modulus - 1, modulus - 1),
        ]
    }

    private func limbs(from value: BigInt) -> MontgomeryFp.Limbs {
        let mask = BigInt(UInt64.max)
        return (
            UInt64(value & mask),
            UInt64((value >> 64) & mask),
            UInt64((value >> 128) & mask),
            UInt64((value >> 192) & mask),
            UInt64((value >> 256) & mask),
            UInt64((value >> 320) & mask)
        )
    }

    private func bytes(from value: BigInt) -> Data {
        var bytes = Data(repeating: 0, count: 48)
        for index in 0..<48 {
            let shift = (47 - index) * 8
            bytes[index] = UInt8((value >> shift) & 0xff)
        }
        return bytes
    }

    private func wideBytes(from value: BigInt) -> Data {
        value == 0 ? Data([0]) : value.magnitude.serialize()
    }

    private func bigInt(from limbs: MontgomeryFp.Limbs) -> BigInt {
        BigInt(limbs.0)
            + (BigInt(limbs.1) << 64)
            + (BigInt(limbs.2) << 128)
            + (BigInt(limbs.3) << 192)
            + (BigInt(limbs.4) << 256)
            + (BigInt(limbs.5) << 320)
    }

    private func mod(_ value: BigInt) -> BigInt {
        let result = value % modulus
        return result >= 0 ? result : result + modulus
    }

    private func powMod(num: BigInt, power: BigInt, modulo: BigInt) throws -> BigInt {
        guard modulo > 0, power >= 0 else {
            struct ExpectedPowerAndModuloGr0: Error {}
            throw ExpectedPowerAndModuloGr0()
        }
        if modulo == 1 { return 0 }

        var result: BigInt = 1
        var base = num
        var exponent = power
        while exponent > 0 {
            if (exponent & 1) != 0 {
                result = (result * base) % modulo
            }
            base = (base * base) % modulo
            exponent >>= 1
        }
        return result
    }

    private func invert(number: BigInt, modulo: BigInt) throws -> BigInt {
        if number.isZero || modulo <= 0 {
            struct ExpectedPositiveInteger: Error {}
            throw ExpectedPositiveInteger()
        }

        var a = mod(number)
        var b = modulo
        var x: BigInt = 0
        var y: BigInt = 1
        var u: BigInt = 1
        var v: BigInt = 0
        while a != 0 {
            let (q, r) = b.quotientAndRemainder(dividingBy: a)
            let m = x - u * q
            let n = y - v * q
            b = a
            a = r
            x = u
            y = v
            u = m
            v = n
        }

        guard b == 1 else {
            struct NoInverseExists: Error {}
            throw NoInverseExists()
        }
        return mod(x)
    }
}
