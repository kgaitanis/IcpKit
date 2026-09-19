//
//  P2.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation

struct P2: ProjectivePoint, Sendable {
   
    let x: Fp2
    let y: Fp2
    let z: Fp2

    init(x: Fp2, y: Fp2, z: Fp2 = .one) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension P2 {
    typealias F = Fp2
    static let zero = Self(x: .one, y: .one, z: .zero)
}

extension P2 {
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
    
    func pairingPrecomputes() throws -> [SimpleProjectivePoint<Fp2>] {
        let affine = try toAffine()
        return try BLS.calcPairingPrecomputes(x: affine.x, y: affine.y)
    }
}
