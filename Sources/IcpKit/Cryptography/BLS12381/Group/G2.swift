//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

// MARK: G2

/// Element of the cyclic subgroup of `E(GF(p^k))` of `order r`.
/// This element has a with a projective point `(x, y , z)` in the `Fp2` field (`E(GF(p^k))`),
/// that **guaranteed** be on the curve.
public struct G2: FiniteGroup, Equatable {
    
    public let point: Point
    
    public init(point: Point) throws {
        self.point =  try point.assertValidity()
    }
}

public extension G2 {
    typealias Point = P2
    
    /// `E₂: y² = x³ + 4(u+1)`
    enum Curve: EllipticCurve {}
}

public extension G2.Curve {
    typealias Group = G2
    
    /// G2 is the order-q subgroup of E2(Fp²) : y² = x³+4(1+√−1),
    /// where Fp2 is Fp[√−1]/(x2+1). #E2(Fp2 ) = h2q, where
    /// G² - 1
    /// h2q
    static let modulus = G1.Curve.P.power(2) - 1
    
    static let order = G1.Curve.order
    
    /// Cofactor
    static let cofactor = BigInt("5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5", radix: 16)!
    
    static let generator = try! G2(
        point: .init(
            x: .init(
                c0: BigInt("024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8", radix: 16)!,
                c1: BigInt("13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e", radix: 16)!
            ),
            y: .init(
                c0: BigInt("0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801", radix: 16)!,
                c1: BigInt("0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be", radix: 16)!
            ),
            z: .one
        )
    )
    
    /// The BLS parameter `x` for BLS12-381
    static let x = G1.Curve.x
    
    static let b = Fp2((BigInt(4), BigInt(4)))
    
    static let hEff = BigInt("bc69f08f2ee75b3584c6a0ea91b352888e2a8e9145ad7689986ff031508ffe1329c2f178731db956d82bf015d1212b02ec0ec69d7477c1ae954cbc06689f6a359894c0adebbf6b4e8020005aaa95551", radix: 16)!
}

struct BadEncodingFlag: Error {}
struct InvalidCompressedG2Point: Error {}
public extension G2 {
    typealias Error = ProjectivePointError
    static let compressedDataByteCount = 96
    static let uncompressedDataByteCount = 192
    
    init(x: Fp2, y: Fp2, z: Fp2) throws {
        try self.init(point: .init(x: x, y: y, z: z))
    }
    
    private static func flags(from data: Data) throws -> (bitC: Bool, bitI: Bool, bitS: Bool) {
        try flags(from: data[0])
    }
    private static func flags(from mByte: UInt8) throws -> (bitC: Bool, bitI: Bool, bitS: Bool) {
        guard mByte != 0x20, mByte != 0x60, mByte != 0xe0 else {
            throw BadEncodingFlag()
        }
        let bitC = (mByte & (1 << 7)) != 0 // compression bit
        let bitI = (mByte & (1 << 6)) != 0 // point at infinity bit
        let bitS = (mByte & (1 << 5)) != 0 // sign bit
        return (bitC, bitI, bitS)
    }

    init(compressedData data: Data) throws {
        guard data.count == Self.compressedDataByteCount else {
            throw Error.invalidByteCount(
                expectedCompressed: Self.compressedDataByteCount,
                orUncompressed: Self.uncompressedDataByteCount,
                butGot: data.count
            )
        }
        let (flagC, flagI, flagS) = try Self.flags(from: data)
        guard flagC else {
            throw BadEncodingFlag()
        }
        var bytes = [UInt8](data)
        bytes[0] = bytes[0] & 0x1f // clear flags
        if flagI {
            // check that all bytes are 0
            guard bytes.allSatisfy({ $0 == 0x00 }) else {
                throw InvalidCompressedG2Point()
            }
            self = .zero
        } else {
            let x1 = os2ip(Data(bytes.removingFirst(Self.compressedDataByteCount/2)))
            let x0 = os2ip(Data(bytes.removingFirst(Self.compressedDataByteCount/2)))
            assert(bytes.isEmpty)
            let x = Fp2(c0: x0, c1: x1)
            
            // `y² = x³ + 4 * (u+1)` <=>
            // `y² = x³ + b`
            let y² = try x.pow(n: 3) + Curve.b
            var y = try y².sqrt()
            guard !y.isZero else {
                throw InvalidCompressedG2Point()
            }
            let P = Curve.P
            let t0 = (y.c0.value * 2) / P
            let t1 = (y.c1.value * 2) / P
            let yBit = (y.c1.value == 0 ? t0 : t1) == 0 ? 1 : 0
            y = flagS && yBit > 0 ? y : y.negated()
            try self.init(x: x, y: y, z: .one)
        }

    }
    
    init(uncompressedData data: Data) throws {
        guard data.count == Self.uncompressedDataByteCount else {
            throw Error.invalidByteCount(
                expectedCompressed: Self.compressedDataByteCount,
                orUncompressed: Self.uncompressedDataByteCount,
                butGot: data.count
            )
        }
     
        // Check if the infinity flag is set
        if (data[0] & (1 << 6)) != 0 {
            self = .zero
        } else {
            var bytes = data
            let x1 = os2ip(bytes.removingFirst(G1.compressedDataByteCount))
            let x0 = os2ip(bytes.removingFirst(G1.compressedDataByteCount))
            let y1 = os2ip(bytes.removingFirst(G1.compressedDataByteCount))
            let y0 = os2ip(bytes.removingFirst(G1.compressedDataByteCount))
            assert(bytes.isEmpty)
            
            try self.init(x: .init(c0: x0, c1: x1), y: .init(c0: y0, c1: y1), z: .one)
        }
    }

    func toData(compress: Bool = true) -> Data {
    
        if compress {
            var x0: BigInt = 0
            var x1: BigInt = 0
            if isZero {
                // set compressed & point-at-infinity bits
                x1 = BLS.exp2_383 + BLS.exp2_382
            } else {
                let affine = try! point.toAffine()
                let x = affine.x
                let y = affine.y
                
                // Is the y-coordinate the lexicographically largest of the two associated with the
                // x-coordinate? If so, set the third-most significant bit so long as this is not
                // the point at infinity.
                let flag: BigInt = {
                    let P = G1.Curve.P
                    return y.c1.value == 0 ? (y.c0.value * 2) / P : (((y.c1.value * 2) / P) != 0) ? 1 : 0
                }()
                
                // set compressed & sign bits
                x1 = x.c1.value + (flag * BLS.exp2_381) + BLS.exp2_383
                x0 = x.c0.value
            }
            return x1.serialize(padToLength: BLS.publicKeyCompressedByteCount) + x0.serialize(padToLength: BLS.publicKeyCompressedByteCount)
        } else {
            if isZero {
                var out = Data(repeating: 0x00, count: 2 * BLS.publicKeyUncompressedByteCount)
                out[0] = 0x40
                return out
            }
            let affine = try! point.toAffine()
            let x0 = affine.x.c0
            let x1 = affine.x.c1
            let y0 = affine.y.c0
            let y1 = affine.y.c1
            return [x1, x0, y1, y0].map {
                $0.value.serialize(padToLength: BLS.publicKeyCompressedByteCount)
            }.reduce(Data(), +)
        }
    }
    
}



extension RangeReplaceableCollection {
    mutating func removingFirst(_ length: Int) -> Self {
        let removed = prefix(length)
        removeFirst(length)
        return Self(removed)
    }
}
