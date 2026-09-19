//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

// MARK: G1

///
/// Element of the cyclic subgroup of `E(GF(p))` of `order r`. This element has a
/// projective point `(x, y, z)` in the `Fp` field (`E(GF(p))`),
/// that **guaranteed** be on the curve.
struct G1: FiniteGroup, Equatable, Sendable {
    let point: Point
    
    init(point: Point) throws {
        self.point =  try point.assertValidity()
    }
    
    init(x: F, y: F, z: F = P1.zDefault) throws {
        try self.init(point: .init(x: x, y: y, z: z))
    }
}

extension G1 {
    typealias F = Point.F
    typealias Point = P1
    
    /// `E₁: y² = x³ + 4`
    enum Curve: EllipticCurve {}
}

extension G1.Curve {
    typealias Group = G1
    /// G1 is the order-q subgroup of `E1(Fp) : y² = x³ + 4, #E1(Fp) = h1q`
    /// where characteristic: `z + (z⁴ - z² + 1)(z - 1)²/3`
    static let modulus: BigInt = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab", radix: 16)!
    
    /// Order: `z⁴ − z² + 1`
    static let order = BigInt("73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001", radix: 16)!
    
    /// Cofactor: `(z - 1)²/3`
    static let cofactor = BigInt("396c8c005555e1568c00aaab0000aaab", radix: 16)!
    
    /// The generator point of a the group `G1`, with coordinates
    /// x = 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507
    /// y = 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569
    static let generator = try! G1(
        x: Fp(value: BigInt("17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb", radix: 16)!),
        y: Fp(value: BigInt("08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1", radix: 16)!),
        z: .one
    )
    
    static let b: BigInt = 4
    /// The BLS parameter x for BLS12-381
    static let x = BigInt("d201000000010000", radix: 16)!
}

extension G1 {
    static let compressedDataByteCount = 48
    static let uncompressedDataByteCount = 96
  
    static let b = Fp(value: G1.Curve.b)
    typealias Error = ProjectivePointError
    init(compressedData: Data) throws {
        guard compressedData.count == Self.compressedDataByteCount else {
            throw Error.invalidByteCount(expectedCompressed: Self.compressedDataByteCount, orUncompressed: Self.uncompressedDataByteCount, butGot: compressedData.count)
        }
        
        let compressedValue = os2ip(compressedData)
        
        let bflag = mod(a: compressedValue, b: BLS.exp2_383) / BLS.exp2_382
        
        if (bflag == 1) {
            self = Self.zero
        } else {
            let x = Fp(value: mod(a: compressedValue, b: BLS.exp2_381))
            let ySquared = try x.pow(n: 3) + Self.b
            guard var y = ySquared.sqrt() else {
                throw Error.invalidCompressedPoint
            }
            
            let aflag = mod(a: compressedValue, b: BLS.exp2_382) / BLS.exp2_381
            
            if ((y.value * 2) / G1.Curve.P) != aflag {
                y.negate()
            }
            
            try self.init(x: x, y: y)
        }
        
    }
    
    init(uncompressedData: Data) throws {
        guard uncompressedData.count == Self.uncompressedDataByteCount else {
            throw Error.invalidByteCount(expectedCompressed: Self.compressedDataByteCount, orUncompressed: Self.uncompressedDataByteCount, butGot: uncompressedData.count)
        }
        
        // Check if the infinity flag is set
        if (uncompressedData[0] & (1 << 6)) != 0 {
            self = .zero
        } else {
            var bytes = [UInt8](uncompressedData)
            let x = os2ip(Data(bytes.removingFirst(Self.compressedDataByteCount)))
            let y = os2ip(Data(bytes.removingFirst(Self.compressedDataByteCount)))
            assert(bytes.isEmpty)
            try self.init(x: .init(value: x), y: .init(value: y))
        }
    }

    
    // MARK: Data Serialization
    func toData(compress: Bool = true) -> Data {
        var out: BigInt
        if compress {
            let P = G1.Curve.P
            if isZero {
                out = BLS.exp2_383 + BLS.exp2_382
            } else {
                let affine = try! point.toAffine()
                let x = affine.x
                let y = affine.y
                let flag = (y.value * 2) / P
                out = x.value + (flag * BLS.exp2_381) + BLS.exp2_383
            }
            return out.serialize(padToLength: Self.compressedDataByteCount)
        } else {
            if isZero {
                var out = Data(repeating: 0x00, count: 2 * Self.compressedDataByteCount)
                out[0] = 0x40
                return out
            } else {
                let affine = try! point.toAffine()
                let x = affine.x
                let y = affine.y
                return x.value.serialize(padToLength: Self.compressedDataByteCount) + y.value.serialize(padToLength: Self.compressedDataByteCount)
            }
        }
        
    }
}
