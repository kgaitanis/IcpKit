//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import BigInt
import Foundation

struct Fp12: Field, CustomDebugStringConvertible {
    let c0: Fp6
    let c1: Fp6
}

extension Fp12 {
    init<C>(coeffs: C) where C: Collection, C.Element == BigInt, C.Index == Int {
        precondition(coeffs.count == 12)
        self.init(c0: .init(coeffs: coeffs.prefix(6)), c1: .init(coeffs: coeffs.suffix(6)))
    }
}

extension Fp12 {
    
    func toString(radix: Int, pad: Bool) -> String {
        """
        \(Self.self)(
            c0: \(c0.toString(radix: radix, pad: pad)),
            c1: \(c1.toString(radix: radix, pad: pad))
        )
        """
    }
}

extension BigInt {
    
    var bitWidthIgnoreSign: Int {
        magnitude.bitWidth
    }
   
}

extension Fp12 {
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
        let c0 = lhs.c0
        let c1 = lhs.c1
        let r0 = rhs.c0
        let r1 = rhs.c1
        let t1 = c0 * r0
        let t2 = c1 * r1
        return Self(
            c0: t1 + t2.mulByNonresidue(),
            c1: (c0 + c1) * (r0 + r1) - (t1 + t2)
        )
    }

    static func / (lhs: Self, rhs: Self) throws -> Self {
        try lhs * rhs.inverted()
    }

    static func * (lhs: Self, rhs: BigInt) -> Self {
        Self(c0: lhs.c0 * rhs, c1: lhs.c1 * rhs)
    }
    
    func multiplyBy014(o0: Fp2, o1: Fp2, o4: Fp2) -> Self {
        let t0 = c0.multiplyBy01(b0: o0, b1: o1)
        let t1 = c1.multiplyBy1(b1: o4)
        return Self(
            c0: t1.mulByNonresidue() + t0,
            c1: (c1 + c0).multiplyBy01(b0: o0, b1: o1 + o4) - t0 - t1
        )
    }
    
    static func * (lhs: Self, rhs: Fp2) -> Fp12 {
        .init(
            c0: lhs.c0 * rhs,
            c1: lhs.c1 * rhs
        )
    }

    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        let inv = try Fp(value: rhs).inverted().value
        return lhs * inv
    }

    func inverted() throws -> Self {
        let t = try (c0.squared() - c1.squared().mulByNonresidue()).inverted()
        return Self(c0: c0 * t, c1: (c1 * t).negated())
    }

    func squared() -> Self {
        let ab = c0 * c1
        return Self(
            c0: (c1.mulByNonresidue() + c0) * (c0 + c1) - ab - ab.mulByNonresidue(),
            c1: ab + ab
        )
    }
    mutating func square() {
        self = self.squared()
    }

    func conjugate() -> Self {
        Self(c0: c0, c1: c1.negated())
    }

    func pow(n: BigInt) throws -> Self {
        try powMod(fqp: self, one: .one, n: n)
    }

    /// Raises to `q**i -th power`
    func frobeniusMap(power: Int) -> Self {
        let r0 = self.c0.frobeniusMap(power: power)
        let t = self.c1.frobeniusMap(power: power)
        let c0 = t.c0
        let c1 = t.c1
        let c2 = t.c2
        let coeff = Frobenius.fp12Coefficients[power % Frobenius.fp12Coefficients.count]
        return Self(
            c0: r0,
            c1: .init(
                c0: c0 * coeff,
                c1: c1 * coeff,
                c2: c2 * coeff
            )
        )
    }

    private func fp4Square(a: Fp2, b: Fp2) -> (first: Fp2, second: Fp2) {
        let a2 = a.squared()
        let b2 = b.squared()
        return (
            first: b2.mulByNonresidue() + a2, // b² * Nonresidue + a²
            second: (a + b).squared() - a2 - b2 // (a + b)² - a² - b²
        )
    }

    // A cyclotomic group is a subgroup of Fp^n defined by
    //   GΦₙ(p) = {α ∈ Fpⁿ : α^Φₙ(p) = 1}
    // The result of any pairing is in a cyclotomic subgroup
    // https://eprint.iacr.org/2009/565.pdf
    func cyclotomicSquare() -> Self {
        let c0c0 = c0.c0
        let c0c1 = c0.c1
        let c0c2 = c0.c2
        let c1c0 = c1.c0
        let c1c1 = c1.c1
        let c1c2 = c1.c2

        let (t3, t4) = fp4Square(a: c0c0, b: c1c1)
        let (t5, t6) = fp4Square(a: c1c0, b: c0c2)
        let (t7, t8) = fp4Square(a: c0c1, b: c1c2)

        let t9 = t8.mulByNonresidue()

        return Fp12(
            c0: Fp6(
                c0: 2 * (t3 - c0c0) + t3,
                c1: 2 * (t5 - c0c1) + t5,
                c2: 2 * (t7 - c0c2) + t7
            ),
            c1: Fp6(
                c0: 2 * (t9 + c1c0) + t9,
                c1: 2 * (t4 + c1c1) + t4,
                c2: 2 * (t6 + c1c2) + t6
            )
        )
    }

    func cyclotomicExp(n: BigInt) -> Self {
        return BitArray(bitPattern: n)
            .prefix(G2.Curve.x.bitWidthIgnoreSign)
            .reversed()
            .reduce(into: Self.one) {
                $0 = $0.cyclotomicSquare()
                if $1 {
                    $0 *= self
                }
            }
    }
    
    // https://eprint.iacr.org/2010/354.pdf
    // https://eprint.iacr.org/2009/565.pdf
    func finalExponentiate() throws -> Self {
        let x = G2.Curve.x
        // this^(q⁶) / this
        let t0 = try frobeniusMap(power: 6) / self
        // t0^(q²) * t0
        let t1 = t0.frobeniusMap(power: 2) * t0
        let t2 = t1.cyclotomicExp(n: x).conjugate()
        let t3 = t1.cyclotomicSquare().conjugate() * t2
        let t4 = t3.cyclotomicExp(n: x).conjugate()
        let t5 = t4.cyclotomicExp(n: x).conjugate()
        let t6 = t5.cyclotomicExp(n: x).conjugate() * t2.cyclotomicSquare()
        let t7 = t6.cyclotomicExp(n: x).conjugate()
        let t2_t5_pow_q2 = (t2 * t5).frobeniusMap(power: 2)
        let t4_t1_pow_q3 = (t4 * t1).frobeniusMap(power: 3)
        let t6_t1c_pow_q1 = (t6 * t1.conjugate()).frobeniusMap(power: 1)
        let t7_t3c_t1 = t7 * t3.conjugate() * t1
        // (t2 * t5)^(q²) * (t4 * t1)^(q³) * (t6 * t1.conj)^(q^1) * t7 * t3.conj * t1
        return t2_t5_pow_q2 * t4_t1_pow_q3 * t6_t1c_pow_q1 * t7_t3c_t1
    }
}

private extension Fp12 {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp6, Fp6) -> Fp6) -> Self {
        .init(
            c0: operation(lhs.c0, rhs.c0),
            c1: operation(lhs.c1, rhs.c1)
        )
    }
}
