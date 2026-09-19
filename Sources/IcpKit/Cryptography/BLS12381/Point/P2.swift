//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation

struct P2: ProjectivePoint {
   
    let x: Fp2
    let y: Fp2
    let z: Fp2
    
    let __storageForPrecomputes: StorageOfPrecomputedProjectivePoints<Self> = .init()
    private let simpleStorageOfPrecomputedPoints: StorageOfPrecomputedSimplePoints = .init()
    
    init(x: Fp2, y: Fp2, z: Fp2 = .one) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension P2 {

    init(privateKey: PrivateKey) {
        fatalError()
    }
    
}

extension P2 {
    typealias F = Fp2
    static let zero = Self(x: .one, y: .one, z: .zero)
}


extension P2 {
    
    /// Encodes byte string to elliptic curve
      /// https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-11#section-3
    static func hashToCurve(
        message: Data,
        hashToFieldConfig: HashToFieldConfig = .defaultForHashToG2
    ) async throws -> Self {
        let u = try await BLS.hashToField(
            message: message,
            elementCount: 2,
            config: hashToFieldConfig
        )

        let t0 = Fp2(c0: u[0][0], c1: u[0][1])
        let Q0 = try Self(simpleProjective: BLS.isogenyMapG2(jacobiPoint: BLS.mapToCurveSimple_swu_9mod16(t: t0)))
        let t1 = Fp2(c0: u[1][0], c1: u[1][1])
        let Q1 = try Self(simpleProjective: BLS.isogenyMapG2(jacobiPoint: BLS.mapToCurveSimple_swu_9mod16(t: t1)))
        
        let R = Q0 + Q1
        let P = try R.clearCofactor()
        return P
    }
    
    /// Checks for equation `y² = x³ + b`
    func isOnCurve() -> Bool {
        do {
            return try _isOnCurve()
        } catch {
            return false
        }
    }
    
    /// Checks for equation `y² = x³ + b`
    func _isOnCurve() throws -> Bool {
        let b = G2.Curve.b
        let left = try y.pow(n: 2) * z - x.pow(n: 3)
        let right = try b * z.pow(n: 3)
        return (left - right).isZero
    }
    
    func mulCurveX() throws -> Self {
        try unsafeMultiply(scalar: G2.Curve.x).negated()
    }
    
    @discardableResult
    func assertValidity() throws -> Self {
        if isZero { return self }
        guard isOnCurve() else {
            throw Error.invalidPointNotOnCurveFp
        }
        guard isTorsionFree() else {
            throw Error.invalidPointNotOfPrimeOrderSubgroup
        }
        // all good
        return self
    }
    
    /// Checks is the point resides in prime-order subgroup.
    func isTorsionFree() -> Bool {
        do {
            return try _isTorsionFree()
        } catch {
            return false
        }
    }
    
    // Checks is the point resides in prime-order subgroup.
    // point.isTorsionFree() should return true for valid points
    // It returns false for shitty points.
    // https://eprint.iacr.org/2021/1130.pdf
    // prettier-ignore
    func _isTorsionFree() throws -> Bool {
      let P = self
      return try P.mulCurveX() == P.psi() // ψ(P) == [u](P)
      // https://eprint.iacr.org/2019/814.pdf
      // const psi2 = P.psi2();                        // Ψ²(P)
      // const psi3 = psi2.psi();                      // Ψ³(P)
      // const zPsi3 = psi3.mulNegX();                 // [z]Ψ³(P) where z = -x
      // return zPsi3.subtract(psi2).add(P).isZero();  // [z]Ψ³(P) - Ψ²(P) + P == O
    }
    
    typealias Error = ProjectivePointError
    
    // Ψ endomorphism
    private func psi() throws -> Self {
        try Self(affine: toAffine().psi())
    }
    
    // Ψ²
    private func psi2() throws -> Self {
        try Self(affine: toAffine().psi2())
    }
    
    // Maps the point into the prime-order subgroup G2.
    // clear_cofactor_bls12381_g2 from cfrg-hash-to-curve-11
    // https://eprint.iacr.org/2017/419.pdf
    func clearCofactor() throws -> Self {
        let P = self
        let t1 = try P.mulCurveX()   // [-x]P
        var t2 = try P.psi()         // Ψ(P)
        var t3 = P.doubled()      // 2P
        t3 = try t3.psi2()           // Ψ²(2P)
        t3 = t3 - t2     // Ψ²(2P) - Ψ(P)
        t2 = t1 + t2          // [-x]P + Ψ(P)
        t2 = try t2.mulCurveX()      // [x²]P - [x]Ψ(P)
        t3 = t3 + t2          // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P)
        t3 = t3 - t1     // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P) + [x]P
        let Q = t3 - P // Ψ²(2P) - Ψ(P) + [x²]P - [x]Ψ(P) + [x]P - 1P =>
        return Q                 // [x²-x-1]P + [x-1]Ψ(P) + Ψ²(2P)
    }
    
    func pairingPrecomputes() throws -> [SimpleProjectivePoint<Fp2>] {
        if let precomputes = self.simpleStorageOfPrecomputedPoints.points {
            return precomputes
        }
        let affine = try toAffine()
        let precomputes = try BLS.calcPairingPrecomputes(x: affine.x, y: affine.y)
        
        self.simpleStorageOfPrecomputedPoints.points = precomputes
        return precomputes
    }
}

extension P2 {
    func toSignature() -> Signature {
        fatalError()
    }

}

extension P2 {
    
    private final class StorageOfPrecomputedSimplePoints {
        fileprivate var points: [SimpleProjectivePoint<Fp2>]?
        fileprivate init(points: [SimpleProjectivePoint<Fp2>]? = nil) {
            self.points = points
        }
    }
}
