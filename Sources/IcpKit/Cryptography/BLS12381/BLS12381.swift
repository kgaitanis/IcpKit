//
//  BLS12381.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation
import CryptoKit // SHA256

/// Utilities for 3-isogeny map from E' to E.
enum Isogeny {
    struct Fp2_4 {
        let elements: [Fp2]

        /// Each 3-isogeny polynomial below has four Fp2 coefficients, listed
        /// from lowest to highest degree in the hash-to-curve appendix.
        static let count = 4

        struct WrongLength: Error {}

        subscript(index: Int) -> Fp2 {
            precondition(index >= 0)
            precondition(index <= Self.count)
            return elements[index]
        }

        init(elements: [Fp2]) throws {
            guard elements.count == Self.count else { throw WrongLength() }
            self.elements = elements
        }
    }

    /// x-coordinate numerator coefficients for the BLS12-381 G2 3-isogeny map.
    ///
    /// Source: hash-to-curve draft, BLS12381G2_XMD:SHA-256_SSWU_RO_ appendix E.3.
    /// Recompute by taking the spec's hexadecimal Fp2 coefficient pairs and
    /// constructing each pair as `Fp2(c0, c1)` in canonical field representation.
    static let xnum = try! Fp2_4(elements: [
        Fp2(
            realHex: "5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6",
            imaginaryHex: "5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6"
        ),
        Fp2(
            realHex: "0",
            imaginaryHex: "11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71a"
        ),
        Fp2(
            realHex: "11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71e",
            imaginaryHex: "8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38d"
        ),
        Fp2(
            realHex: "171d6541fa38ccfaed6dea691f5fb614cb14b4e7f4e810aa22d6108f142b85757098e38d0f671c7188e2aaaaaaaa5ed1",
            imaginaryHex: "0"
        )
    ])

    /// x-coordinate denominator coefficients for the same 3-isogeny map.
    ///
    /// Source/recompute method is the same as `xnum`; small coefficients such as
    /// `0x0c` and `1` are literal Fp values from the spec table.
    static let xden = try! Fp2_4(elements: [
        Fp2(
            realHex: "0",
            imaginaryHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa63"
        ),
        Fp2(
            realHex: "0c",
            imaginaryHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa9f"
        ),
        Fp2((1, 0)),
        Fp2((0, 0))
    ])

    /// y-coordinate numerator coefficients for the same 3-isogeny map.
    ///
    /// Source/recompute method is the same as `xnum`.
    static let ynum = try! Fp2_4(elements: [
        Fp2(
            realHex: "1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706",
            imaginaryHex: "1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706"
        ),
        Fp2(
            realHex: "0",
            imaginaryHex: "5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97be"
        ),
        Fp2(
            realHex: "11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71c",
            imaginaryHex: "8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38f"
        ),
        Fp2(
            realHex: "124c9ad43b6cf79bfbf7043de3811ad0761b0f37a1e26286b0e977c69aa274524e79097a56dc4bd9e1b371c71c718b10",
            imaginaryHex: "0"
        )
    ])

    /// y-coordinate denominator coefficients for the same 3-isogeny map.
    ///
    /// Source/recompute method is the same as `xnum`; `0x12` and `1` are literal
    /// Fp values from the spec table.
    static let yden = try! Fp2_4(elements: [
        Fp2(
            realHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb",
            imaginaryHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb"
        ),
        Fp2(
            realHex: "0",
            imaginaryHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa9d3"
        ),
        Fp2(
            realHex: "12",
            imaginaryHex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa99"
        ),
        Fp2((1, 0))
    ])

    /// The isogeny coefficient blocks in evaluation order:
    /// x numerator, x denominator, y numerator, y denominator.
    static let coefficients: [Fp2_4] = [xnum, xden, ynum, yden]
    
}

// For info about different ciphersuites see
// https://www.ietf.org/id/draft-irtf-cfrg-bls-signature-05.html#name-ciphersuites-for-bls12-381
enum BLS {}
extension BLS {

    /// Cubic extension generator `v` represented in Fp6 = Fp2[v]/(v^3 - (u + 1)).
    /// It is used to embed the Fp6 nonresidue into Fp12 Frobenius constants.
    static let utRoot = Fp6(c0: .zero, c1: .one, c2: .zero)

    /// `v` embedded into Fp12 as the c0 component.
    static let wsq = Fp12(c0: utRoot, c1: .zero)

    /// `w` embedded into Fp12 as the c1 component.
    static let wcu = Fp12(c0: .zero, c1: utRoot)

    /// Batched inverses of `wsq` and `wcu`.
    /// Recompute with Montgomery field inversion; batching saves one inversion.
    static let (wsqInv, wcuInv) = {
        let invertedBatch = try! generateInvertedBatch(
            fieldType: Fp12.self,
            numbers: [wsq, wcu])
        assert(invertedBatch.count == 2)
        return (wsqInv: invertedBatch[0], wcuInv: invertedBatch[1])
    }()
    
    static func generateInvertedBatch<F: Field>(
        fieldType: F.Type,
        numbers: [F]
    ) throws -> [F] {
        
        var tmp = [F](repeating: F.zero, count: numbers.count)
        
        // Walk from first to last, multiply them by each other MOD p
        let lastMultiplied: F = numbers.enumerated().reduce(F.one) { acc, enumeratedTuple in
            let (numberIndex, number) = enumeratedTuple
            guard !number.isZero else { return acc }
            tmp[numberIndex] = acc
            return acc * number
        }
        
        let inverted = try lastMultiplied.inverted()
        

        // Walk from last to first, multiply them by inverted each other MOD p
        _ = numbers.indices.reversed().reduce(inverted) { acc, invertedIndex in
            let number = numbers[invertedIndex]
            guard !number.isZero else { return acc }
            tmp[invertedIndex] *= acc
            return acc * number
        }
        
        return tmp
    }
    
    
    // 3-isogeny map from E' to E
    // Converts from Jacobi (xyz) to Projective (xyz) coordinates.
    // https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#appendix-E.3
    static func isogenyMapG2(jacobiPoint: ProjectivePointFp2) -> ProjectivePointFp2 {
        
        let x = jacobiPoint.x
        let y = jacobiPoint.y
        let z = jacobiPoint.z
        
        let zz = z * z
        let zzz = zz * z
        let zPowers = [z, zz, zzz]
        
        // x-numerator, x-denominator, y-numerator, y-denominator
        var mapped = [Fp2.zero, Fp2.zero, Fp2.zero, Fp2.zero]
        
        // Horner Polynomial Evaluation
        for (i, k_i) in Isogeny.coefficients.enumerated() {
            mapped[i] = k_i.elements.last!
            let arr = k_i.elements.prefix(upTo: Isogeny.Fp2_4.count - 1).reversed()
            for (j, k_i_j) in arr.enumerated() {
                let tmpA = mapped[i] * x
                let tmpB = zPowers[j] * k_i_j
                mapped[i] = tmpA + tmpB
                
            }
        }
        mapped[2] = mapped[2] * y // y-numerator * y
        mapped[3] = mapped[3] * z // y-denominator * z
        
        let z2 = mapped[1] * mapped[3]
        let x2 = mapped[0] * mapped[3]
        let y2 = mapped[1] * mapped[2]
        return ProjectivePointFp2(x: x2, y: y2, z: z2)
    }
    
    // Pre-compute coefficients for sparse multiplication
    // Point addition and point double calculations is reused for coefficients
    static func calcPairingPrecomputes(x: Fp2, y: Fp2) throws -> [ProjectivePointFp2] {
        let Qx = x
        let Qy = y
        let Qz = Fp2.one
        
        var Rx = Qx
        var Ry = Qy
        var Rz = Qz
        
        var ellCoefficients: [ProjectivePointFp2] = []
        
        
        for bitX in BitArray(bitPattern: G1.Curve.x)
            .prefix(G1.Curve.x.bitWidth - G1.Curve.x.leadingZeroBitCount - 1)
            .reversed() {
            // Double
            let t0 = Ry.squared() // Ry²
            let t1 = Rz.squared() // Rz²
            let t2 = (t1 * 3).multiplyByB() // 3 * T1 * B
            let t3 = t2 * 3
            let t4 = (Ry + Rz).squared() - t1 - t0 // (Ry + Rz)² - T1 - T0
            
            ellCoefficients.append(
                ProjectivePointFp2(
                    x: t2 - t0,
                    y: 3 * Rx.squared(),
                    z: t4.negated()
                )
            )
            
            Rx = try ((t0 - t3) * Rx * Ry) / 2
            Ry = try ((t0 + t3) / 2).squared() - (3 * t2.squared())
            Rz = t0 * t4
            
            if bitX {
                // Addition
                let t0 = Ry - (Qy * Rz)
                let t1 = Rx - (Qx * Rz)
                let ecX = (t0 * Qx) - (t1 * Qy)
                let ecY = t0.negated()
                let ecZ = t1

                ellCoefficients.append(
                    ProjectivePointFp2(
                        x: ecX,
                        y: ecY,
                        z: ecZ
                    )
                )
                
                let t2 = t1.squared() // T1²
                let t3 = t2 * t1
                let t4 = t2 * Rx
                let t5 = t3 - (2 * t4) + (t0.squared() * Rz)
                Rx = t1 * t5
                Ry = ((t4 - t5) * t0) - (t3 * Ry)
                Rz = Rz * t3
            }
        }
        
        return ellCoefficients
    }
    
    static func millerLoop(ell: [ProjectivePointFp2], g1: AffinePoint<Fp>) -> Fp12 {
        let Px = g1.x
        let Py = g1.y
        var f12 = Fp12.one
        var j = 0

        for (i, bitX) in BitArray(bitPattern: G1.Curve.x)
            .prefix(G1.Curve.x.bitWidth - G1.Curve.x.leadingZeroBitCount - 1)
            .enumerated()
            .reversed()
        {
            defer { j += 1 }
            let E = ell[j]
            f12 = f12.multiplyBy014(o0: E.x, o1: E.y * Px, o4: E.z * Py)
            if bitX {
                j += 1
                let F = ell[j]
                f12 = f12.multiplyBy014(o0: F.x, o1: F.y * Px, o4: F.z * Py)
            }
            if i != 0 {
                f12.square()
            }
        }
        return f12.conjugate()
    }

    static func millerLoop(terms: [(ell: [ProjectivePointFp2], g1: AffinePoint<Fp>)]) -> Fp12 {
        let affineG1 = terms.map { (ell: $0.ell, px: $0.g1.x, py: $0.g1.y) }
        var f12 = Fp12.one
        var j = 0

        for (i, bitX) in BitArray(bitPattern: G1.Curve.x)
            .prefix(G1.Curve.x.bitWidth - G1.Curve.x.leadingZeroBitCount - 1)
            .enumerated()
            .reversed()
        {
            defer { j += 1 }
            for term in affineG1 {
                let E = term.ell[j]
                f12 = f12.multiplyBy014(o0: E.x, o1: E.y * term.px, o4: E.z * term.py)
            }
            if bitX {
                j += 1
                for term in affineG1 {
                    let F = term.ell[j]
                    f12 = f12.multiplyBy014(o0: F.x, o1: F.y * term.px, o4: F.z * term.py)
                }
            }
            if i != 0 {
                f12.square()
            }
        }
        return f12.conjugate()
    }
    
    /// Implementation of algorithm [`expand_message_xmd`][reference].
    ///
    ///     expand_message_xmd(msg, DST, len_in_bytes)
    ///
    ///     Parameters:
    ///     - H, a hash function (see requirements above).
    ///     - b_in_bytes, b / 8 for b the output size of H in bits.
    ///       For example, for b = 256, b_in_bytes = 32.
    ///     - r_in_bytes, the input block size of H, measured in bytes (see
    ///       discussion above). For example, for SHA-256, r_in_bytes = 64.
    ///
    ///     Input:
    ///     - msg, a byte string.
    ///     - DST, a byte string of at most 255 bytes.
    ///       See below for information on using longer DSTs.
    ///     - len_in_bytes, the length of the requested output in bytes.
    ///
    ///     Output:
    ///     - uniform_bytes, a byte string.
    ///
    ///     Steps:
    ///     1.  ell = ceil(len_in_bytes / b_in_bytes)
    ///     2.  ABORT if ell > 255
    ///     3.  DST_prime = DST || I2OSP(len(DST), 1)
    ///     4.  Z_pad = I2OSP(0, r_in_bytes)
    ///     5.  l_i_b_str = I2OSP(len_in_bytes, 2)
    ///     6.  msg_prime = Z_pad || msg || l_i_b_str || I2OSP(0, 1) || DST_prime
    ///     7.  b_0 = H(msg_prime)
    ///     8.  b_1 = H(b_0 || I2OSP(1, 1) || DST_prime)
    ///     9.  for i in (2, ..., ell):
    ///     10.    b_i = H(strxor(b_0, b_(i - 1)) || I2OSP(i, 1) || DST_prime)
    ///     11. uniform_bytes = b_1 || ... || b_ell
    ///     12. return substr(uniform_bytes, 0, len_in_bytes)
    ///
    /// [reference]: https://www.ietf.org/archive/id/draft-irtf-cfrg-hash-to-curve-10.html#name-expand_message_xmd-2
    // Calculates bilinear pairing
    static func pairing(
        g1: G1,
        g2: G2,
        withFinalExponent: Bool = true
    ) throws -> Fp12 {
        guard !g1.isZero, !g2.isZero else {
            throw NoPairingExistsAtPointOfInfinity()
        }
        let looped = try g1.point.millerLoop(p2: g2.point)
        return try withFinalExponent ? looped.finalExponentiate() : looped
    }
    
    
}
struct NoPairingExistsAtPointOfInfinity: Error {}
