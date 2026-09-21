//
//  MontgomeryFp.swift
//
//  Created by Konstantinos Gaitanis on 20.09.26.
//

import BigInt
import Foundation

struct MontgomeryFp: Equatable, Sendable {
    typealias Limbs = (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)

    private let limbs: Limbs

    init(canonicalLimbs: Limbs) {
        precondition(!Self.isGreaterThanOrEqualToModulus(canonicalLimbs))
        self.limbs = Self.montgomeryMultiply(canonicalLimbs, Self.rSquared)
    }

    init(canonicalBytes: Data) throws {
        guard canonicalBytes.count == Self.byteCount else {
            throw InvalidByteCount()
        }
        let limbs = Self.limbs(fromCanonicalBytes: canonicalBytes)
        guard !Self.isGreaterThanOrEqualToModulus(limbs) else {
            throw NonCanonicalFieldElement()
        }
        self.init(canonicalLimbs: limbs)
    }

    init(reducingWideBytes bytes: Data) {
        var result = Self.zero
        var index = bytes.startIndex

        let leadingByteCount = bytes.count % MemoryLayout<UInt64>.size
        if leadingByteCount > 0 {
            result = Self(canonicalLimbs: (Self.word(fromBigEndianBytes: bytes[index..<index + leadingByteCount]), 0, 0, 0, 0, 0))
            index += leadingByteCount
        }

        while index < bytes.endIndex {
            result = result * Self.twoTo64 + Self(canonicalLimbs: (Self.word(fromBigEndianBytes: bytes[index..<index + 8]), 0, 0, 0, 0, 0))
            index += 8
        }
        self = result
    }

    private init(montgomeryLimbs: Limbs) {
        self.limbs = montgomeryLimbs
    }

    var canonicalLimbs: Limbs {
        var words = Words13(low: limbs)
        return Self.montgomeryReduce(&words)
    }

    var canonicalBytes: Data {
        Self.canonicalBytes(from: canonicalLimbs)
    }

    var value: BigInt {
        os2ip(canonicalBytes)
    }

    var isZero: Bool {
        self == .zero
    }

    var isOdd: Bool {
        (canonicalLimbs.0 & 1) == 1
    }

    var isLexicographicallyLargest: Bool {
        Self.isGreaterThan(canonicalLimbs, Self.halfModulus)
    }

    func isGreaterThan(_ other: Self) -> Bool {
        Self.isGreaterThan(canonicalLimbs, other.canonicalLimbs)
    }

    static let zero = Self(montgomeryLimbs: (0, 0, 0, 0, 0, 0))
    static let one = Self(montgomeryLimbs: r)

    init(value: BigInt) {
        self.init(canonicalLimbs: Self.limbs(from: mod(a: value, b: Self.modulusValue)))
    }

    init(hex: String) {
        try! self.init(canonicalBytes: Self.canonicalBytes(fromHex: hex))
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.limbs.0 == rhs.limbs.0
            && lhs.limbs.1 == rhs.limbs.1
            && lhs.limbs.2 == rhs.limbs.2
            && lhs.limbs.3 == rhs.limbs.3
            && lhs.limbs.4 == rhs.limbs.4
            && lhs.limbs.5 == rhs.limbs.5
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(montgomeryLimbs: addMod(lhs.limbs, rhs.limbs))
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(montgomeryLimbs: subtractMod(lhs.limbs, rhs.limbs))
    }

    func negated() -> Self {
        self == .zero ? .zero : Self(montgomeryLimbs: Self.subtractMod(Self.modulus, limbs))
    }

    func multiplied(bySmall scalar: UInt64) -> Self {
        var result = Self.zero
        var base = self
        var scalar = scalar

        while scalar > 0 {
            if (scalar & 1) != 0 {
                result = result + base
            }
            base = base + base
            scalar >>= 1
        }

        return result
    }

    func dividedBy2() -> Self {
        Self(montgomeryLimbs: Self.divideBy2(limbs))
    }

    static func * (lhs: Self, rhs: Self) -> Self {
        Self(montgomeryLimbs: montgomeryMultiply(lhs.limbs, rhs.limbs))
    }

    static func / (lhs: Self, rhs: Self) throws -> Self {
        try lhs * rhs.inverted()
    }

    func inverted() throws -> Self {
        guard self != .zero else {
            throw DivisionByZero()
        }
        return pow(exponent: Self.pMinus2)
    }

    func squared() -> Self {
        self * self
    }

    func pow(exponent: UInt64) -> Self {
        var result = Self.one
        var base = self
        var exponent = exponent

        while exponent > 0 {
            if (exponent & 1) != 0 {
                result = result * base
            }
            base = base.squared()
            exponent >>= 1
        }

        return result
    }

    func sqrt() -> Self? {
        let root = pow(exponent: Self.sqrtExponent)
        return root.squared() == self ? root : nil
    }

}

private extension MontgomeryFp {
    static let byteCount = 48
    static let modulusValue = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab", radix: 16)!

    struct InvalidByteCount: Error {}
    struct NonCanonicalFieldElement: Error {}
    struct DivisionByZero: Error {}

    // BLS12-381 base-field modulus:
    // p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab,
    // split into six little-endian 64-bit limbs.
    static let modulus: Limbs = (
        0xb9feffffffffaaab,
        0x1eabfffeb153ffff,
        0x6730d2a0f6b0f624,
        0x64774b84f38512bf,
        0x4b1ba7b6434bacd7,
        0x1a0111ea397fe69a
    )

    static let halfModulus: Limbs = (
        0xdcff7fffffffd555,
        0x0f55ffff58a9ffff,
        0xb39869507b587b12,
        0xb23ba5c279c2895f,
        0x258dd3db21a5d66b,
        0x0d0088f51cbff34d
    )

    // p - 2, the inverse exponent from Fermat's little theorem, as little-endian limbs.
    static let pMinus2: Limbs = (
        0xb9feffffffffaaa9,
        0x1eabfffeb153ffff,
        0x6730d2a0f6b0f624,
        0x64774b84f38512bf,
        0x4b1ba7b6434bacd7,
        0x1a0111ea397fe69a
    )

    // (p + 1) / 4, valid for square roots because p == 3 mod 4.
    static let sqrtExponent: Limbs = (
        0xee7fbfffffffeaab,
        0x07aaffffac54ffff,
        0xd9cc34a83dac3d89,
        0xd91dd2e13ce144af,
        0x92c6e9ed90d2eb35,
        0x0680447a8e5ff9a6
    )

    // Montgomery reduction factor n' = -p^-1 mod 2^64.
    static let montgomeryInv: UInt64 = 0x89f3fffcfffcfffd

    // Montgomery radix R = 2^384 reduced modulo p, stored as little-endian limbs.
    static let r: Limbs = (
        0x760900000002fffd,
        0xebf4000bc40c0002,
        0x5f48985753c758ba,
        0x77ce585370525745,
        0x5c071a97a256ec6d,
        0x15f65ec3fa80e493
    )

    // R^2 mod p, used to convert canonical values into Montgomery form:
    // montgomeryMultiply(x, R^2) = xR mod p.
    static let rSquared: Limbs = (
        0xf4df1f341c341746,
        0x0a76e6a609d104f1,
        0x8de5476c4c95b6d5,
        0x67eb88a9939d83c0,
        0x9a793e85b519952d,
        0x11988fe592cae3aa
    )

    static let twoTo64 = Self(canonicalLimbs: (0, 1, 0, 0, 0, 0))

    static func montgomeryMultiply(_ lhs: Limbs, _ rhs: Limbs) -> Limbs {
        var product = Words13()

        for i in 0..<6 {
            for j in 0..<6 {
                let multiplied = limb(lhs, at: i).multipliedFullWidth(by: limb(rhs, at: j))
                add(multiplied.low, to: &product, at: i + j)
                add(multiplied.high, to: &product, at: i + j + 1)
            }
        }

        return montgomeryReduce(&product)
    }

    func pow(exponent: Limbs) -> MontgomeryFp {
        var result = Self.one

        for limbIndex in (0..<6).reversed() {
            let limb = Self.limb(exponent, at: limbIndex)
            for bitIndex in (0..<64).reversed() {
                result = result.squared()
                if ((limb >> UInt64(bitIndex)) & 1) != 0 {
                    result = result * self
                }
            }
        }

        return result
    }

    static func montgomeryReduce(_ words: inout Words13) -> Limbs {
        for i in 0..<6 {
            let factor = words[i] &* montgomeryInv
            for j in 0..<6 {
                let multiplied = factor.multipliedFullWidth(by: limb(modulus, at: j))
                add(multiplied.low, to: &words, at: i + j)
                add(multiplied.high, to: &words, at: i + j + 1)
            }
        }

        let result = (words[6], words[7], words[8], words[9], words[10], words[11])
        return words[12] != 0 || isGreaterThanOrEqualToModulus(result) ? subtractModulus(result).limbs : result
    }

    static func addMod(_ lhs: Limbs, _ rhs: Limbs) -> Limbs {
        let sum = addRaw(lhs, rhs)
        if sum.carry || isGreaterThanOrEqualToModulus(sum.limbs) {
            return subtractModulus(sum.limbs).limbs
        }
        return sum.limbs
    }

    static func subtractMod(_ lhs: Limbs, _ rhs: Limbs) -> Limbs {
        let difference = subtractRaw(lhs, rhs)
        if difference.borrow {
            return addRaw(difference.limbs, modulus).limbs
        }
        return difference.limbs
    }

    static func divideBy2(_ limbs: Limbs) -> Limbs {
        let value = (limbs.0 & 1) == 0 ? limbs : addRaw(limbs, modulus).limbs
        return shiftRightByOne(value)
    }

    static func shiftRightByOne(_ limbs: Limbs) -> Limbs {
        let value = array(limbs)
        var result = [UInt64](repeating: 0, count: 6)
        var carry: UInt64 = 0

        for index in (0..<6).reversed() {
            result[index] = (value[index] >> 1) | carry
            carry = (value[index] & 1) << 63
        }

        return tuple(result)
    }

    static func addRaw(_ lhs: Limbs, _ rhs: Limbs) -> (limbs: Limbs, carry: Bool) {
        let left = array(lhs)
        let right = array(rhs)
        var result = [UInt64](repeating: 0, count: 6)
        var carry = false

        for i in 0..<6 {
            let first = left[i].addingReportingOverflow(right[i])
            let second = first.partialValue.addingReportingOverflow(carry ? 1 : 0)
            result[i] = second.partialValue
            carry = first.overflow || second.overflow
        }

        return (tuple(result), carry)
    }

    static func subtractRaw(_ lhs: Limbs, _ rhs: Limbs) -> (limbs: Limbs, borrow: Bool) {
        let left = array(lhs)
        let right = array(rhs)
        var result = [UInt64](repeating: 0, count: 6)
        var borrow = false

        for i in 0..<6 {
            let first = left[i].subtractingReportingOverflow(right[i])
            let second = first.partialValue.subtractingReportingOverflow(borrow ? 1 : 0)
            result[i] = second.partialValue
            borrow = first.overflow || second.overflow
        }

        return (tuple(result), borrow)
    }

    static func subtractModulus(_ limbs: Limbs) -> (limbs: Limbs, borrow: Bool) {
        subtractRaw(limbs, modulus)
    }

    static func isGreaterThanOrEqualToModulus(_ limbs: Limbs) -> Bool {
        isGreaterThanOrEqualTo(limbs, modulus)
    }

    static func isGreaterThan(_ lhs: Limbs, _ rhs: Limbs) -> Bool {
        let left = array(lhs)
        let right = array(rhs)
        for i in (0..<6).reversed() {
            if left[i] > right[i] { return true }
            if left[i] < right[i] { return false }
        }
        return false
    }

    static func isGreaterThanOrEqualTo(_ lhs: Limbs, _ rhs: Limbs) -> Bool {
        let value = array(lhs)
        let modulus = array(rhs)
        for i in (0..<6).reversed() {
            if value[i] > modulus[i] { return true }
            if value[i] < modulus[i] { return false }
        }
        return true
    }

    static func add(_ value: UInt64, to words: inout [UInt64], at index: Int) {
        guard value != 0 else { return }
        var index = index
        var carry = value

        while carry != 0 {
            let sum = words[index].addingReportingOverflow(carry)
            words[index] = sum.partialValue
            carry = sum.overflow ? 1 : 0
            index += 1
        }
    }

    static func add(_ value: UInt64, to words: inout Words13, at index: Int) {
        guard value != 0 else { return }
        var index = index
        var carry = value

        while carry != 0 {
            let sum = words[index].addingReportingOverflow(carry)
            words[index] = sum.partialValue
            carry = sum.overflow ? 1 : 0
            index += 1
        }
    }

    static func limb(_ limbs: Limbs, at index: Int) -> UInt64 {
        switch index {
        case 0: limbs.0
        case 1: limbs.1
        case 2: limbs.2
        case 3: limbs.3
        case 4: limbs.4
        case 5: limbs.5
        default: preconditionFailure("Invalid limb index")
        }
    }

    static func array(_ limbs: Limbs) -> [UInt64] {
        [limbs.0, limbs.1, limbs.2, limbs.3, limbs.4, limbs.5]
    }

    static func tuple(_ limbs: [UInt64]) -> Limbs {
        precondition(limbs.count == 6)
        return (limbs[0], limbs[1], limbs[2], limbs[3], limbs[4], limbs[5])
    }

    static func limbs(fromCanonicalBytes bytes: Data) -> Limbs {
        precondition(bytes.count == byteCount)
        var limbs = [UInt64](repeating: 0, count: 6)

        for byteIndex in 0..<byteCount {
            let littleEndianByteIndex = byteCount - 1 - byteIndex
            let limbIndex = littleEndianByteIndex / 8
            let shift = UInt64((littleEndianByteIndex % 8) * 8)
            limbs[limbIndex] |= UInt64(bytes[byteIndex]) << shift
        }

        return tuple(limbs)
    }

    static func limbs(from value: BigInt) -> Limbs {
        precondition(value >= 0 && value < modulusValue)
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

    static func canonicalBytes(from limbs: Limbs) -> Data {
        let limbs = array(limbs)
        var bytes = Data(repeating: 0, count: byteCount)

        for byteIndex in 0..<byteCount {
            let littleEndianByteIndex = byteCount - 1 - byteIndex
            let limbIndex = littleEndianByteIndex / 8
            let shift = UInt64((littleEndianByteIndex % 8) * 8)
            bytes[byteIndex] = UInt8((limbs[limbIndex] >> shift) & 0xff)
        }

        return bytes
    }

    static func canonicalBytes(fromHex hex: String) -> Data {
        precondition(hex.count <= byteCount * 2)
        var paddedHex = String(repeating: "0", count: byteCount * 2 - hex.count) + hex
        var bytes = Data()
        while !paddedHex.isEmpty {
            let byteHex = String(paddedHex.prefix(2))
            bytes.append(UInt8(byteHex, radix: 16)!)
            paddedHex.removeFirst(2)
        }
        return bytes
    }

    static func word(fromBigEndianBytes bytes: Data.SubSequence) -> UInt64 {
        precondition(bytes.count <= MemoryLayout<UInt64>.size)
        var result: UInt64 = 0
        for byte in bytes {
            result = (result << 8) | UInt64(byte)
        }
        return result
    }
}

private struct Words13 {
    private var w0: UInt64
    private var w1: UInt64
    private var w2: UInt64
    private var w3: UInt64
    private var w4: UInt64
    private var w5: UInt64
    private var w6: UInt64
    private var w7: UInt64
    private var w8: UInt64
    private var w9: UInt64
    private var w10: UInt64
    private var w11: UInt64
    private var w12: UInt64

    init() {
        self.init(
            w0: 0,
            w1: 0,
            w2: 0,
            w3: 0,
            w4: 0,
            w5: 0,
            w6: 0,
            w7: 0,
            w8: 0,
            w9: 0,
            w10: 0,
            w11: 0,
            w12: 0
        )
    }

    init(low limbs: MontgomeryFp.Limbs) {
        self.init(
            w0: limbs.0,
            w1: limbs.1,
            w2: limbs.2,
            w3: limbs.3,
            w4: limbs.4,
            w5: limbs.5,
            w6: 0,
            w7: 0,
            w8: 0,
            w9: 0,
            w10: 0,
            w11: 0,
            w12: 0
        )
    }

    private init(
        w0: UInt64,
        w1: UInt64,
        w2: UInt64,
        w3: UInt64,
        w4: UInt64,
        w5: UInt64,
        w6: UInt64,
        w7: UInt64,
        w8: UInt64,
        w9: UInt64,
        w10: UInt64,
        w11: UInt64,
        w12: UInt64
    ) {
        self.w0 = w0
        self.w1 = w1
        self.w2 = w2
        self.w3 = w3
        self.w4 = w4
        self.w5 = w5
        self.w6 = w6
        self.w7 = w7
        self.w8 = w8
        self.w9 = w9
        self.w10 = w10
        self.w11 = w11
        self.w12 = w12
    }

    subscript(index: Int) -> UInt64 {
        get {
            switch index {
            case 0: w0
            case 1: w1
            case 2: w2
            case 3: w3
            case 4: w4
            case 5: w5
            case 6: w6
            case 7: w7
            case 8: w8
            case 9: w9
            case 10: w10
            case 11: w11
            case 12: w12
            default: preconditionFailure("Invalid word index")
            }
        }
        set {
            switch index {
            case 0: w0 = newValue
            case 1: w1 = newValue
            case 2: w2 = newValue
            case 3: w3 = newValue
            case 4: w4 = newValue
            case 5: w5 = newValue
            case 6: w6 = newValue
            case 7: w7 = newValue
            case 8: w8 = newValue
            case 9: w9 = newValue
            case 10: w10 = newValue
            case 11: w11 = newValue
            case 12: w12 = newValue
            default: preconditionFailure("Invalid word index")
            }
        }
    }
}
