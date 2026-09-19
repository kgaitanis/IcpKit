//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt
import CryptoKit // SHA256

/// Utilities for 3-isogeny map from E' to E.
enum Isogeny {
    struct Fp2_4: ExpressibleByArrayLiteral {
        let elements: [Fp2]
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
        init(bigInts: [BigInt]) throws {
            guard bigInts.count == Self.count*2 else { throw WrongLength() }
            try self.init(elements: bigInts.chunks(ofCount: 2).map(Fp2.init))
        }
        init(arrayLiteral bigInts: BigInt...) {
            try! self.init(bigInts: bigInts)
        }
    }
    
    private static let a97d6 = BigInt("5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6", radix: 16)!
    private static let d706 = BigInt("1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706", radix: 16)!
    private static let a8fb = BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb", radix: 16)!
    
    static let xnum: Fp2_4 = [
        a97d6,
        a97d6,
        0,
        BigInt("11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71a", radix: 16)!,
        BigInt("11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71e", radix: 16)!,
        BigInt("8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38d", radix: 16)!,
        BigInt("171d6541fa38ccfaed6dea691f5fb614cb14b4e7f4e810aa22d6108f142b85757098e38d0f671c7188e2aaaaaaaa5ed1", radix: 16)!,
        0
    ]
    
    static let xden: Fp2_4 = [
        0,
        BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa63", radix: 16)!,
        0x0c,
        BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa9f", radix: 16)!,
        1,
        0,
        0,
        0
    ]
    
    static let ynum: Fp2_4 = [
        d706,
        d706,
        0,
        BigInt("5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97be", radix: 16)!,
        BigInt("11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71c", radix: 16)!,
        BigInt("8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38f", radix: 16)!,
        BigInt("124c9ad43b6cf79bfbf7043de3811ad0761b0f37a1e26286b0e977c69aa274524e79097a56dc4bd9e1b371c71c718b10", radix: 16)!,
        0
    ]
    
    static let yden: Fp2_4 = [
        a8fb,
        a8fb,
        0,
        BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa9d3", radix: 16)!,
        0x12,
        BigInt("1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa99", radix: 16)!,
        1,
        0
    ]
    
    static let coefficients: [Fp2_4] = [xnum, xden, ynum, yden]
    
}

// For info about different ciphersuites see
// https://www.ietf.org/id/draft-irtf-cfrg-bls-signature-05.html#name-ciphersuites-for-bls12-381
enum BLS {}
extension BLS {
    
    /// `C_bit`, compression bit for serialization flag
    static let exp2_381 = BigInt(2).power(381)
    
    /// `I_bit`, point-at-infinity bit for serialization flag
    static let exp2_382 = exp2_381 * 2
    
    /// `S_bit`, sign bit for serialization flag
    static let exp2_383 = exp2_382 * 2
    
    static let publicKeyCompressedByteCount = G1.compressedDataByteCount
    static let publicKeyUncompressedByteCount = G1.uncompressedDataByteCount
}


extension BLS {
    
    static let utRoot = Fp6(c0: .zero, c1: .one, c2: .zero)
    static let wsq = Fp12(c0: utRoot, c1: .zero)
    static let wcu = Fp12(c0: .zero, c1: utRoot)
    
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
            .prefix(G1.Curve.x.bitWidthIgnoreSign-1)
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
        let Px = g1.x.value
        let Py = g1.y.value
        var f12 = Fp12.one
        var j = 0

        for (i, bitX) in BitArray(bitPattern: G1.Curve.x)
            .prefix(G1.Curve.x.bitWidthIgnoreSign-1)
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
    static func expandMessageXMD(
        toLength outputByteCount: Int,
        message: Data,
        domainSeperationTag: DomainSeperationTag
    ) async throws -> Data {
        
        let bInBytes = SHA256.byteCount
        let rInBytes = bInBytes * 2
        let ell = Int(ceil(Double(outputByteCount) / Double(bInBytes)))
        guard ell <= 255 else {
            struct InvalidXMDLength: Error {}
            throw InvalidXMDLength()
        }
        
        let dst = domainSeperationTag.dataNoLongerThan255ElseHashed(mode: .expandMessageXMD)

        return await Task {
            let dstPrime = dst + i2osp(dst.count, 1)
            let zPad = i2osp(0, rInBytes)
            let outputByteCountData = i2osp(outputByteCount, 2)
            let messagePrime = Data(SHA256.hash(data: zPad + message + outputByteCountData + i2osp(0, 1) + dstPrime))
            
            var b: [Data] = []
            
            let firstB = Data(
                SHA256.hash(
                    data: messagePrime + i2osp(1, 1) + dstPrime
                )
            )
            
            b.append(firstB)
            for i in 1...ell {
                let hashInputRHS = b.last!
                let hashInput0 = Data(zip(messagePrime, hashInputRHS).map { $0 ^ $1 })
                let hashInput = hashInput0 + i2osp(i + 1, 1) + dstPrime
                let hash = Data(SHA256.hash(
                    data: hashInput
                ))
                b.append(hash)
            }
            let pseudoRandomBytes: Data = b.reduce(Data(), +)
            assert(pseudoRandomBytes.count >= outputByteCount)
            let outResult = pseudoRandomBytes.prefix(outputByteCount)
            return outResult
        }.result.get()
    }
    
    static let p²Minus9div16: BigInt = {
        (G1.Curve.P.power(2) - 9) / 16
    }()
    
    // Does not return a square root.
    // Returns uv⁷ * (uv¹⁵)^((p² - 9) / 16) * root of unity
    // if valid square root is found
    static func sqrtDivFp2(u: Fp2, v: Fp2) throws -> (success: Bool, sqrtCandidateOrGamma: Fp2) {
        let v⁷ = try v.pow(n: 7)
        let uv⁷ = u * v⁷
        let uv¹⁵ = uv⁷ * v⁷ * v
        let gamma = try uv¹⁵.pow(n: p²Minus9div16) * uv⁷
        var success = false
        var result = gamma
      
        let positiveRootsOfUnity = Fp2.rootsOfUnity.prefix(4)

        // Constant-time routine, so we do not early-return.
        for root in positiveRootsOfUnity {
            // Valid if (root * gamma)² * v - u == 0
            let candidate = root * gamma
            // Constant-time routine, so we do not early-return.
            if try (candidate.pow(n: 2) * v - u).isZero && !success {
                success = true
                result = candidate
            }
            // Constant-time routine, so we do not early-return.
        }
  
        return (success, sqrtCandidateOrGamma: result)
    }
    
    
    // Optimized SWU Map - Fp2 to G2': y² = x³ + 240i * x + 1012 + 1012i
    // Found in Section 4 of https://eprint.iacr.org/2019/403
    // Note: it's constant-time
    // https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#appendix-G.2.3
    static func mapToCurveSimple_swu_9mod16(t: Fp2) throws -> SimpleProjectivePoint<Fp2> {
        let iso_3_a = Fp2(c0: .zero, c1: .init(value: 240))
        let iso_3_b = Fp2(c0: .init(value: 1012), c1: .init(value: 1012))
        let iso_3_z = Fp2(c0: .init(value: -2), c1: .init(value: -1))
        let t² = try t.pow(n: 2)
        let iso_3_z_t2 = iso_3_z * t²
        let ztzt = iso_3_z_t2 + (try iso_3_z_t2.pow(n: 2)) // (Z * t² + Z² * t⁴)
        var denominator = iso_3_a * (ztzt.negated()) // -a(Z * t² + Z² * t⁴)
        var numerator = iso_3_b * (ztzt + Fp2.one) // b(Z * t² + Z² * t⁴ + 1)
        
        // Exceptional case
        if denominator.isZero {
            denominator = iso_3_z * iso_3_a
        }
        
        let D² = try denominator.pow(n: 2)
        
        /// aka `v`
        let D³ = try denominator.pow(n: 3)
        
        let N³ = try numerator.pow(n: 3)
        // u = N³ + a * N * D² + b * D³
        var u = N³ + (iso_3_a * numerator * D²) + (iso_3_b * D³)
      
        // Attempt y = sqrt(u / v)
        var y: Fp2!
        let sqrtCandidateOrGammaSuccessOrNot = try sqrtDivFp2(u: u, v: D³)
        let success = sqrtCandidateOrGammaSuccessOrNot.success
        let sqrtCandidateOrGamma = sqrtCandidateOrGammaSuccessOrNot.sqrtCandidateOrGamma
        if success {
            y = sqrtCandidateOrGamma
        }
        
        // Handle case where (u / v) is not square
        let t³ = try t.pow(n: 3)
        let sqrtCandidateX1 = sqrtCandidateOrGamma * t³
        
        // u(x1) = Z³ * t⁶ * u(x0)
        u = try iso_3_z_t2.pow(n: 3) * u
        var success2 = false
        
        // Constant-time routine, so we do not early-return.
        for eta in Fp2.etas {
            // Valid solution if (eta * sqrt_candidate(x1))² * v - u == 0
            let etaSqrtCandidate = eta * sqrtCandidateX1
            let temp = try etaSqrtCandidate.pow(n:2) * D³ - u
            // Constant-time routine, so we do not early-return.
            if temp.isZero && !success && !success2 {
                y = etaSqrtCandidate
                success2 = true
            }
            // Constant-time routine, so we do not early-return.
        }
        
        guard success || success2 else {
            struct HashToCurveOptimizedSWUFailure: Error {}
            throw HashToCurveOptimizedSWUFailure()
        }
        
        if success2 {
            numerator *= iso_3_z_t2
        }

        if t.sgn0() != y.sgn0() {
            y.negate()
        }
        y *= denominator
        return .init(x: numerator, y: y, z: denominator)
    }

    static func hashToField(
        message: Data,
        elementCount: Int,
        config: HashToFieldConfig = .defaultForHashToG2
    ) async throws -> [[BigInt]] {
        let L = config.L
        let byteCount = L * elementCount * config.m
        var pseudoRandomBytes = message
        if config.expand {
            pseudoRandomBytes = try await expandMessageXMD(
                toLength: byteCount,
                message: message,
                domainSeperationTag: config.domainSeperationTag
            )
        }
        var u: [[BigInt]] = []
        for i in 0..<elementCount {
            var e: [BigInt] = []
            for j in 0..<config.m {
                let elmOffset = L * (j + i * config.m)
                let tv = pseudoRandomBytes[elmOffset..<elmOffset+L]
                let eElement = mod(a: os2ip(tv), b: config.p)
                e.append(eElement)
            }
            u.append(e)
        }
        return u
    }
    
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

/// Octet Stream to Integer
///
/// Defined as: `BigInt(sign: .plus, magnitude: BigUInt(data))`
///
/// Note that we get the wrong result if we do: `BigInt(data)`
///
/// Effectively what we are doing is this
///
///     data.reduce(into: BigInt(0)) {
///         $0 <<= 8
///         $0 += BigInt($1)
///     }
func os2ip(_ data: Data) -> BigInt {
    BigInt(sign: .plus, magnitude: BigUInt(data))
}

struct DomainSeperationTag: Sendable, Equatable, ExpressibleByStringLiteral {
    let _data: Data
    enum Mode {
        case expandMessageXOF
        case expandMessageXMD
    }
    
    func toString(encoding: String.Encoding = .utf8) -> String {
        String(data: _data, encoding: encoding)!
    }
    
    /// https://www.ietf.org/archive/id/draft-irtf-cfrg-hash-to-curve-10.html#section-5.4.3
    func dataNoLongerThan255ElseHashed(mode: Mode = .expandMessageXMD) -> Data {
        if _data.count <= 255 {
            return _data
        } else {
            let prefixData = "H2C-OVERSIZE-DST-".data(using: .ascii)!
            switch mode {
            case .expandMessageXMD:
                return Data(SHA256.hash(data: prefixData + _data))
            case .expandMessageXOF:
                fatalError("Unsupported")
            }
        }
    }
    init(data: Data) {
        precondition(data.count > 0)
        precondition(data.count <= 2048)
        self._data = data
    }
    
      // https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-3.1
    init(_ string: String) {
        self.init(data: string.data(using: .utf8)!)
    }
    init(stringLiteral value: String) {
        self.init(value)
    }
    
    // https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-8.8.2
    static let g2Basic: Self = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_"
    
    /// Proof of possession
    static let g2Pop: Self = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_POP_"
}

struct HashToFieldConfig: Equatable {
    /// Domain seperation tag, aka `DST`.
    let domainSeperationTag: DomainSeperationTag
    /// The characteristic of F, where `F` is a finite field of *characteristic* `p` and *order* `q = p^m`
    let p: BigInt
    
    /// The extension degree of F, m >= 1, where F is a finite field of characteristic p and order q = p^m
    let m: Int

    /// The target security level for the suite in bits [defined in reference][reference]
    ///
    /// [reference]: https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-5.1
    let k: Int
    
    /// option to use a message that has already been processed by
    /// expand_message_xmd
    let expand: Bool
    
    init(
        domainSeperationTag: DomainSeperationTag = .g2Basic,
        p: BigInt = G1.Curve.P,
        m: Int = 2,
        k: Int = 128,
        expand: Bool = true
    ) {
        self.domainSeperationTag = domainSeperationTag
        self.p = p
        self.m = m
        self.k = k
        self.expand = expand
    }
}
extension HashToFieldConfig {
    static let defaultForHashToG2 = Self()
}

extension HashToFieldConfig {
    
    /// https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-5.1
    var L: Int {
        let log2p = p.bitWidthIgnoreSign
        let L = ceil((Double(log2p) + Double(k)) / 8)
        return Int(L)
    }
}


func i2osp(_ value: Int, _ length: Int) -> Data {
    let preconditionFailureMessage = "Bad I2OSP call, value: \(value), length: \(length)"
    precondition(value >= 0, preconditionFailureMessage)
//    if value >= (1 << (8 * length)) {
//        preconditionFailure(preconditionFailureMessage)
//    }
    var value = value
    var result = Data(repeating: 0x00, count: length)
    for i in 0..<length {
        result[length - 1 - i] = UInt8(value & 0xff)
        value >>= 8
    }
    return result
}
