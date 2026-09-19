//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

/// Finite field over `p`.
public struct Fp: FiniteField {
    public let value: BigInt
    init(value: BigInt) {
        self.value = mod(a: value, b: Self.order)//value % Self.order
    }
}

// MARK: CustomStringConvertible
public extension Fp {
    
    func toString(radix: Int = 16, pad: Bool) -> String {
        _toString(
            radix: radix,
            pad: pad ? (radix == 16 ? Pad.toLength(96) : Pad.toLength(115)) : nil
        )
    }
    
    private func _toString(radix: Int = 16, pad: Pad?) -> String {
        value.toString(radix: radix, pad: pad)
    }
}

func mod(a: BigInt, b: BigInt) -> BigInt {
    let res = a % b
    return res >= 0 ? res : b + res
}

/// Inverses number over modulo
func invert(number: BigInt, modulo: BigInt) throws -> BigInt {
    if number.isZero || modulo <= 0 {
        struct ExpectedPositiveInteger: Error {}
        throw ExpectedPositiveInteger()
    }
    // Eucledian GCD https://brilliant.org/wiki/extended-euclidean-algorithm/
    var a = mod(a: number, b: modulo)
    var b = modulo
    var x: BigInt = 0
    var y: BigInt = 1
    var u: BigInt = 1
    var v: BigInt = 0
    while a != 0 {
        let (q, r) = b.quotientAndRemainder(dividingBy: a)
        let m = x - u * q
        let n = y - v * q
        b = a; a = r; x = u; y = v; u = m; v = n;
    }
    let gcd = b
    guard gcd == 1 else {
        struct NoInverseExists: Error {}
        throw NoInverseExists()
    }
    return mod(a: x, b: modulo)
}

public extension Fp {
    
    /// The order of this field equals the modulus of G1.
    static let order = G1.Curve.modulus
    
    static let zero = Self(value: 0)
    static let one = Self(value: 1)
    
    func negated() -> Self {
        var valueCopy = value
        valueCopy.negate()
        return Self(value: valueCopy)
    }
    
    func inverted() throws -> Self {
        let inverse = try invert(number: value, modulo: order)
        return Self(value: inverse)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, +)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, -)
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
       op(lhs, rhs, *)
    }
    
    static func / (lhs: Self, rhs: Self) throws -> Self {
        try lhs * rhs.inverted()
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        Self.init(value: lhs.value * rhs)
    }
    
    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        try lhs / Self(value: rhs)
    }
    
    func squared() throws -> Self {
       try pow(n: 2)
    }
    
    func pow(n: BigInt) throws -> Self {
        try .init(value: powMod(num: value, power: n, modulo: order))
    }
    
    // square root computation for p ≡ 3 (mod 4)
    // a^((p-3)/4)) ≡ 1/√a (mod p)
    // √a ≡ a * 1/√a ≡ a^((p+1)/4) (mod p)
    // It's possible to unwrap the exponentiation, but (P+1)/4 has 228 1's out of 379 bits.
    // https://eprint.iacr.org/2012/685.pdf
    func sqrt() -> Self? {
        guard let root = try? pow(n: (order + 1) / 4) else {
            return nil
        }
        guard let rootSquared = try? root.squared() else { return nil }
        if rootSquared != self { return nil }
        return root
    }
}

/**
 * Efficiently exponentiate num to power and do modular division.
 * @example
 * powMod(2n, 6n, 11n) // 64n % 11n == 9n
 */
func powMod(num: BigInt, power: BigInt, modulo: BigInt) throws -> BigInt {
    guard modulo > 0, power >= 0 else {
        struct ExpectedPowerAndModuloGr0: Error {}
        throw ExpectedPowerAndModuloGr0()
    }
    if modulo == 1 { return 0 }
    var res: BigInt = 1
    var num = num
    var power = power
    while power > 0 {
        if ((power & 1) != 0) {
            res = (res * num) % modulo
        }
        num = (num * num) % modulo
        power >>= 1
    }
    return res
    
}
//export function powMod(num: bigint, power: bigint, modulo: bigint) {
//    if (modulo <= 0n || power < 0n) throw new Error('Expected power/modulo > 0');
//    if (modulo === 1n) return 0n;
//    let res = 1n;
//    while (power > 0n) {
//        if (power & 1n) res = (res * num) % modulo;
//        num = (num * num) % modulo;
//        power >>= 1n;
//    }
//    return res;
//}

private extension Fp {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (BigInt, BigInt) -> BigInt) -> Self {
        .init(value: operation(lhs.value, rhs.value))
    }
}

