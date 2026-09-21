//
//  Fp2.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation

/// Fp₂ over complex plane
struct Fp2: FiniteField, Sendable {
    /// Real part, aka `c0`
    let c0: Fp
    
    /// Imaginary part, aka `c1`
    let c1: Fp
    
    init(c0: Fp, c1: Fp) {
        self.c0 = c0
        self.c1 = c1
    }
}
private struct BadCount: Error {}
extension Fp2 {
    init(realHex: String, imaginaryHex: String) {
        self.init(c0: Fp(hex: realHex), c1: Fp(hex: imaginaryHex))
    }
    init(_ tuple: (Int, Int)) {
        self.init(c0: Fp(tuple.0), c1: Fp(tuple.1))
    }
    init(_ tuple: (Fp, Fp)) {
        self.init(c0: tuple.0, c1: tuple.1)
    }
    init(_ collection: some Collection<Fp>) throws {
        guard collection.count == 2 else {
            throw BadCount()
        }
        self.init(c0: collection[collection.startIndex], c1: collection[collection.index(after: collection.startIndex)])
    }
}

extension Fp2 {
    static let zero = Self(c0: .zero, c1: .zero)
    static let one = Self(c0: .one, c1: .zero)
    
    func negated() -> Self {
        .init(c0: c0.negated(), c1: c1.negated())
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, +)
    }
    static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs, rhs, -)
    }
    static func * (lhs: Self, rhs: Self) -> Self {
        // Karatsuba form of (A + Bi)(C + Di), using i^2 = -1.
        // This saves one base-field multiplication versus computing AD + BC directly.
        let A = lhs.c0
        let B = lhs.c1
        let C = rhs.c0
        let D = rhs.c1
        let ac = A * C
        let bd = B * D
        let abcd = (A + B) * (C + D)
        return .init(c0: ac - bd, c1: abcd - ac - bd)
    }
    static func / (lhs: Self, rhs: Self) throws -> Self {
        let inv = try rhs.inverted()
        return lhs * inv
    }
    
    static func * (lhs: Self, rhs: Fp) -> Self {
        .init(c0: lhs.c0 * rhs, c1: lhs.c1 * rhs)
    }
    
    /// We wish to find the multiplicative inverse of a nonzero
    /// element a + bu in Fp2. We leverage an identity
    ///
    /// (a + bu)(a - bu) = a² + b²
    ///
    /// which holds because u² = -1. This can be rewritten as
    ///
    /// (a + bu)(a - bu)/(a² + b²) = 1
    ///
    /// because a² + b² = 0 has no nonzero solutions for (a, b).
    /// This gives that (a - bu)/(a² + b²) is the inverse
    /// of (a + bu). Importantly, this can be computing using
    /// only a single inversion in Fp.
    func inverted() throws -> Self {
        let factor = try (c0.squared() + c1.squared()).inverted()
        return .init(c0: factor * c0, c1: (factor * c1).negated())
    }
    
    func squared() -> Self {
        let a = c0 + c1
        let b = c0 - c1
        let c = c0 + c0
        return .init(c0: a * b, c1: c * c1)
    }
    
    func pow(exponent: UInt64) throws -> Self {
        try powMod(fqp: self, one: .one, exponent: exponent)
    }

    private func pow(exponentLimbs: [UInt64]) throws -> Self {
        try powMod(fqp: self, one: .one, exponentLimbs: exponentLimbs)
    }
    
    // TODO: Optimize this line. It's extremely slow.
    // Speeding this up would boost aggregateSignatures.
    // https://eprint.iacr.org/2012/685.pdf applicable?
    // https://github.com/zkcrypto/bls12_381/blob/080eaa74ec0e394377caa1ba302c8c121df08b07/src/fp2.rs#L250
    // https://github.com/supranational/blst/blob/aae0c7d70b799ac269ff5edf29d8191dbd357876/src/exp2.c#L1
    // Inspired by https://github.com/dalek-cryptography/curve25519-dalek/blob/17698df9d4c834204f83a3574143abacb4fc81a5/src/field.rs#L99
    func sqrt() throws -> Fp2 {
        let candidateSqrt = try pow(exponentLimbs: Self.squareRootExponent)
        let check = try candidateSqrt.squared() / self
        let R = Self.rootsOfUnity
        guard let divisor = [R[0], R[2], R[4], R[6]].first(where: { $0 == check }) else {
            struct NoDivisor: Error {}
            throw NoDivisor()
        }
  
        guard let divisorIndex = R.firstIndex(where: { $0 == divisor }) else {
            struct NoDivisorIndex: Error {}
            throw NoDivisorIndex()
        }
        let root = R[divisorIndex / 2]
        let x1 = try candidateSqrt / root
        let x2 = x1.negated()
        if x1.isGreaterThan(x2) {
            return x1
        }
        return x2
    }
}

extension Fp2 {
    /// For `roots of unity`.
    static let rv1 = Fp(hex: "6af0e0437ff400b6831e36d6bd17ffe48395dabc2d3435e77f76e17009241c5ee67992f72ec05f4c81084fbede3cc09")

}


extension Fp2 {
    
    /// Eighth roots of unity, used for computing square roots in Fp2.
    /// To verify or re-calculate:
    static let rootsOfUnity: [Self] = {
        let tuples: [(Fp, Fp)] = [
            (.one, .zero),
            (rv1, rv1.negated()),
            (.zero, .one),
            (rv1, rv1),
            (.one.negated(), .zero),
            (rv1.negated(), rv1),
            (.zero, .one.negated()),
            (rv1.negated(), rv1.negated())
        ]
        return tuples.map(Self.init)
    }()
    
    /// Multiply by: `u + 1`
    func mulByNonresidue() -> Self {
        .init(
            c0: c0 - c1,
            c1: c0 + c1
        )
    }
    
    /// Raises to `q**i -th power`
     func frobeniusMap(power: Int) -> Self {
         .init(
            c0: c0,
            c1: c1 * Frobenius.fp2Coefficients[power % Frobenius.fp2Coefficients.count]
        )
     }
    
    func multiplyByB() -> Self {
        let t0 = c0 * 4
        let t1 = c1 * 4
        return .init(c0: t0 - t1, c1: t0 + t1)
    }
    
    var isLexicographicallyLargest: Bool {
        c1.isLexicographicallyLargest || (c1 == .zero && c0.isLexicographicallyLargest)
    }

    func isGreaterThan(_ other: Self) -> Bool {
        c1.isGreaterThan(other.c1) || (c1 == other.c1 && c0.isGreaterThan(other.c0))
    }

    func sgn0() -> Bool {
        c0.isOdd || (c0 == .zero && c1.isOdd)
    }
    
    /*
     function sgn0(x: Fp2) {
       const {re: x0, im: x1} = x.reim();
       const sign_0 = x0 % 2n;
       const zero_0 = x0 === 0n;
       const sign_1 = x1 % 2n;
       return sign_0 || (zero_0 && sign_1);
     }
     */
}

private extension Fp2 {
    // (p^2 + 8) / 16, where p is the BLS12-381 base-field modulus.
    // Stored as little-endian 64-bit limbs so Fp2 square roots avoid arbitrary-precision arithmetic.
    static let squareRootExponent: [UInt64] = [
        0xb26aa00001c718e4,
        0xd7ced6b1d76382ea,
        0x3162c338362113cf,
        0x966bf91ed3e71b74,
        0xb292e85a87091a04,
        0x11d68619c86185c7,
        0xef53149330978ef0,
        0x050a62cfd16ddca6,
        0x466e59e49349e8bd,
        0x9e2dc90e50e7046b,
        0x74bd278eaa22f25e,
        0x002a437a4b8c35fc
    ]

    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp, Fp) -> Fp) -> Self {
        .init(
            c0: operation(lhs.c0, rhs.c0),
            c1: operation(lhs.c1, rhs.c1)
        )
    }
}

func powMod<F: Field>(
    fqp: F,
    one: F,
    exponent: UInt64
) throws -> F {
    if exponent == 0 { return one }
    if exponent == 1 { return fqp }

    var exponent = exponent
    var result = one
    var base = fqp
    while exponent > 0 {
        if (exponent & 1) != 0 {
            result = result * base
        }
        exponent >>= 1
        base = try base.squared()
    }
    return result
}

func powMod<F: Field>(
    fqp: F,
    one: F,
    exponentLimbs: [UInt64]
) throws -> F {
    var result = one
    var base = fqp
    for limb in exponentLimbs {
        var bits = limb
        for _ in 0..<UInt64.bitWidth {
            if (bits & 1) != 0 {
                result = result * base
            }
            bits >>= 1
            base = try base.squared()
        }
    }
    return result
}
