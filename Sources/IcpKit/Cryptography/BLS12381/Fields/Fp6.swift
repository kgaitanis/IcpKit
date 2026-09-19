//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation
import BigInt

public struct Fp6: Field, CustomDebugStringConvertible {
    public let c0: Fp2
    public let c1: Fp2
    public let c2: Fp2
    public init(c0: Fp2, c1: Fp2, c2: Fp2) {
        self.c0 = c0
        self.c1 = c1
        self.c2 = c2
    }
}

public extension Fp6 {
    
    init<C>(coeffs: C) where C: Collection, C.Element == BigInt, C.Index == Int {
        precondition(coeffs.count == 6)
        self.init(
            c0: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 0)],
                c1: coeffs[coeffs.startIndex.advanced(by: 1)]
            ),
            c1: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 2)],
                c1: coeffs[coeffs.startIndex.advanced(by: 3)]
            ),
            c2: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 4)],
                c1: coeffs[coeffs.startIndex.advanced(by: 5)]
            )
        )
    }
    
    init<C>(coeffs: C) where C: Collection, C.Element == Fp, C.Index == Int {
        precondition(coeffs.count == 6)
        self.init(
            c0: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 0)],
                c1: coeffs[coeffs.startIndex.advanced(by: 1)]
            ),
            c1: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 2)],
                c1: coeffs[coeffs.startIndex.advanced(by: 3)]
            ),
            c2: .init(
                c0: coeffs[coeffs.startIndex.advanced(by: 4)],
                c1: coeffs[coeffs.startIndex.advanced(by: 5)]
            )
        )
    }
}

public extension Fp6 {
    
    func toString(radix: Int, pad: Bool) -> String {
        """
        \(Self.self)(
            c0: \(c0.toString(radix: radix, pad: pad)),
            c1: \(c1.toString(radix: radix, pad: pad))
            c2: \(c2.toString(radix: radix, pad: pad))
        )
        """
    }

}

internal enum Frobenius {
    static let aaaa = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaaa", radix: 16)!
    
    /// Used by `psi2C1` and Fp6 (one and two) and Fp12
    static let aaac = BigInt("1a0111ea397fe699ec02408663d4de85aa0d857d89759ad4897d29650fb85f9b409427eb4f49fffd8bfd00000000aaac", radix: 16)!
    
    /// Used by Fp6 and Fp12
    static let aaad = BigInt("1a0111ea397fe699ec02408663d4de85aa0d857d89759ad4897d29650fb85f9b409427eb4f49fffd8bfd00000000aaad", radix: 16)!
    
    /// Used by Fp6 one and two
    static let fffe = BigInt("00000000000000005f19672fdf76ce51ba69c6076a0f77eaddb3a93be6f89688de17d813620a00022e01fffffffefffe", radix: 16)!
   
        
    /// Finite extension field over irreducible polynominal.
    /// `Fp(u) / (u² - β) where β = -1`
    static let fp2Coefficients: [Fp] = [
        BigInt(1),
        aaaa
    ].map(Fp.init)

    
    static let fp6Coefficients1: [Fp2] = {
        let pairs: [(BigInt, BigInt)] = [
            (1, 0),
            (0, aaac),
            (fffe, 0),
            (0, 1),
            (aaac, 0),
            (0, fffe),
        ]
        precondition(pairs.count == 6)
        return pairs.map { Fp2(c0: $0.0, c1: $0.1) }
    }()
    
    
    static let fp6Coefficients2: [Fp2] = {
        let pairs: [(BigInt, BigInt)] = [
            (1, 0),
            (aaad, 0),
            (aaac, 0),
            (aaaa, 0),
            (fffe, 0),
            (ffff, 0),
        ]
        precondition(pairs.count == 6)
        return pairs.map { Fp2(c0: $0.0, c1: $0.1) }
    }()
    
    /// used by Fp6 two and Fp12
    static let ffff = BigInt("00000000000000005f19672fdf76ce51ba69c6076a0f77eaddb3a93be6f89688de17d813620a00022e01fffffffeffff", radix: 16)!
    
    /// used by Fp12
    static let fb8 = BigInt("1904d3bf02bb0667c231beb4202c0d1f0fd603fd3cbd5f4f7b2443d784bab9c4f67ea53d63e7813d8d0775ed92235fb8", radix: 16)!
    
    /// used by Fp12
    static let af3 = BigInt("00fc3e2b36c4e03288e9e902231f9fb854a14787b6c7b36fec0c8ec971f63c5f282d5ac14d6c7ec22cf78a126ddc4af3", radix: 16)!

    /// used by Fp12
    static let e980078116 = BigInt("05b2cfd9013a5fd8df47fa6b48b1e045f39816240c0b8fee8beadf4d8e9c0566c63a3e6e257f87329b18fae980078116", radix: 16)!
    
    /// used by Fp12
    static let f82995 = BigInt("144e4211384586c16bd3ad4afa99cc9170df3560e77982d0db45f3536814f0bd5871c1908bd478cd1ee605167ff82995", radix: 16)!
    
    /// used by Fp12
    static let dea2 =  BigInt("135203e60180a68ee2e9c448d77a2cd91c3dedd930b1cf60ef396489f61eb45e304466cf3e67fa0af1ee7b04121bdea2", radix: 16)!
    
    /// used by Fp12
    static let cc09 = BigInt("06af0e0437ff400b6831e36d6bd17ffe48395dabc2d3435e77f76e17009241c5ee67992f72ec05f4c81084fbede3cc09", radix: 16)!
    
 
    static let fp12Coefficients: [Fp2] = {
        let pairs: [(BigInt, BigInt)] = [
            (1, 0),
            (fb8, af3),
            (ffff, 0),
            (dea2, cc09),
            (fffe, 0),
            (f82995, e980078116),
            (aaaa, 0),
            (af3, fb8),
            (aaac, 0),
            (cc09, dea2),
            (aaad, 0),
            (e980078116, f82995)
        ]
        precondition(pairs.count == 12)
        return pairs.map(Fp2.init)
    }()
      
}

public extension Fp6 {
    
    static let zero = Self.init(c0: .zero, c1: .zero, c2: .zero)
    
    /// `one` is declared as `(1, 0, 0)`
    static let one = Self.init(c0: .one, c1: .zero, c2: .zero)
    
    func negated() -> Self {
        .init(
            c0: c0.negated(),
            c1: c1.negated(),
            c2: c2.negated()
        )
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
        let c2 = lhs.c2
        let r0 = rhs.c0
        let r1 = rhs.c1
        let r2 = rhs.c2
        let t0 = c0 * r0
        let t1 = c1 * r1
        let t2 = c2 * r2
        
        return .init(
            c0: ((c1 + c2) * (r1 + r2) - (t1 + t2)).mulByNonresidue() + t0,
            c1: (c0 + c1) * (r0 + r1) - (t0 + t1) + t2.mulByNonresidue(),
            c2: (c0 + c2) * (r0 + r2) - (t0 + t2) + t1
        )
    }
    
    static func / (lhs: Self, rhs: Self) throws -> Self {
        try lhs * rhs.inverted()
    }
    
    static func * (lhs: Self, rhs: BigInt) -> Self {
        .init(c0: lhs.c0 * rhs, c1: lhs.c1 * rhs, c2: lhs.c2 * rhs)
    }
    
    static func / (lhs: Self, rhs: BigInt) throws -> Self {
        let inv = try Fp(value: rhs).inverted().value
        return lhs * inv
    }
 
    func inverted() throws -> Self {
        
        /// `t0 = c0² - c2 * c1 * (u + 1)`
        let t0 = c0.squared() - (c2 * c1).mulByNonresidue()
        
        /// `t1 = c2² * (u + 1) - c0 * c1`
        let t1 = c2.squared().mulByNonresidue() - c0 * c1
        
        /// `t2 = c1² - c0 * c2`
        let t2 = c1.squared() - (c0 * c2)
        
        /// `t4 = 1/(((c2 * T1 + c1 * t2) * v) + c0 * t0)`
        let t4 = try (((c2 * t1) + (c1 * t2)).mulByNonresidue() + (c0 * t0)).inverted()
  
        return .init(
            c0: t4 * t0,
            c1: t4 * t1,
            c2: t4 * t2
        )
    }
    
    func squared() -> Self {
        let two = BigInt(2)
        
        /// `t0 = c0²`
        let t0 = c0.squared()
        
        /// `t1 = c0 * c1 * 2`
        let t1 = c0 * c1 * two
        
        /// `t3 = c1 * c2 * 2`
        let t3 = c1 * c2 * two
        
        /// `t4 = c2²`
        let t4 = c2.squared()
       
        return Self(
            c0: t3.mulByNonresidue() + t0, // T3 * (u + 1) + T0
            c1: t4.mulByNonresidue() + t1, // T4 * (u + 1) + T1
            
            // T1 + (c0 - c1 + c2)² + T3 - T0 - T4
            c2: t1 + (c0 - c1 + c2).squared() + t3 - t0 - t4
        )
    }
    
    
    func pow(n: BigInt) throws -> Self {
        try powMod(fqp: self, one: .one, n: n)
    }
}

public extension Fp6 {
    /// Multiply by quadratic nonresidue v.
    func mulByNonresidue() -> Self {
        .init(
            c0: c2.mulByNonresidue(),
            c1: c0,
            c2: c1
        )
    }
    
    /// Sparse multiplication
    func multiplyBy1(b1: Fp2) -> Self {
        .init(
            c0: (c2 * b1).mulByNonresidue(),
            c1: c0 * b1,
            c2: c1 * b1
        )
    }
    
    /// Sparse multiplication
    func multiplyBy01(b0: Fp2, b1: Fp2) -> Self {
        let t0 = c0 * b0
        let t1 = c1 * b1
        return .init(
            c0: ((c1 + c2) * b1 - t1).mulByNonresidue() + t0,
            c1: (b0 + b1) * (c0 + c1) - t0 - t1,
            c2: (c0 + c2) * b0 - t0 + t1
        )
    }
    
    /// Raises to `q**i -th power`
    func frobeniusMap(power: Int) -> Self {
        .init(
            c0: c0.frobeniusMap(power: power),
            c1: c1.frobeniusMap(power: power) * Frobenius.fp6Coefficients1[power % Frobenius.fp6Coefficients1.count],
            c2: c2.frobeniusMap(power: power) * Frobenius.fp6Coefficients2[power % Frobenius.fp6Coefficients2.count]
      )
    }
    
    static func * (lhs: Self, rhs: Fp2) -> Self {
        .init(
            c0: lhs.c0 * rhs,
            c1: lhs.c1 * rhs,
            c2: lhs.c2 * rhs
        )
    }
}

private extension Fp6 {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Fp2, Fp2) -> Fp2) -> Self {
        .init(
            c0: operation(lhs.c0, rhs.c0),
            c1: operation(lhs.c1, rhs.c1),
            c2: operation(lhs.c2, rhs.c2)
        )
    }
}
