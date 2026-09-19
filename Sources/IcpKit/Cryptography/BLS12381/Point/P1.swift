//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-25.
//

import Foundation
import BigInt

// MARK: P1

/// Projective point `(x, y , z)` in the `Fp` field, that **might not** be on the curve,
/// (belong to the group G1)
///
/// We add `z` because we work with projective coordinates instead of affine `x-y`,
/// which results in faster performance.
public struct P1: ProjectivePoint, Equatable {
    public let __storageForPrecomputes: StorageOfPrecomputedProjectivePoints<Self>
    public let x: Fp
    public let y: Fp
    public let z: Fp
    
    public init(x: Fp, y: Fp, z: Fp = Self.zDefault) {
        self.x = x
        self.y = y
        self.z = z
        self.__storageForPrecomputes = .init()
    }
}

// MARK: Init
public extension P1 {
    static let zDefault = Fp.one
   
}

// MARK: Constants
public extension P1 {
    typealias F = Fp
    

}

// MARK: Public
public extension P1 {
    @discardableResult
    func assertValidity() throws -> Self {
        if isZero {
            return self
        }
        guard isOnCurve() else {
            throw Error.invalidPointNotOnCurveFp
        }
        guard isTorsionFree() else {
            throw Error.invalidPointNotOfPrimeOrderSubgroup
        }
        // all good
        return self
    }
    
    // Sparse multiplication against precomputed coefficients
    func millerLoop(p2: P2) throws -> Fp12 {
        let ell = try p2.pairingPrecomputes()
        let g1 = try self.toAffine()
        return BLS.millerLoop(ell: ell, g1: g1)
    }
    
    // Clear cofactor of G1
    // https://eprint.iacr.org/2019/403
    func clearCofactor() throws -> Self {
        let t = try mulCurveMinusX()
        return t + self
    }
}

// MARK: ProjectivePoint
public extension P1 {
    /// Checks that equation is fulfilled: `y² = x³ + b`
    func isOnCurve() -> Bool {
        do {
            return try _isOnCurve()
        } catch {
            return false
        }
    }

}

// MARK: Private
private extension P1 {
    /// `σ endomorphism`
    func sigma() throws -> P1 {
        let beta = Frobenius.aaac
        let affine = try toAffine()
        let x = affine.x
        let y = affine.y
        return Self.init(x: x * beta, y: y)
    }
    
    // φ endomorphism
    func phi() -> Self {
        let cubicRootOfUnityModP = Frobenius.fffe
        return Self(
            x: x * cubicRootOfUnityModP,
            y: y,
            z: z
        )
    }
    
    /// Checks is the point resides in prime-order subgroup.
    func isTorsionFree() -> Bool {
        do {
            return try _isTorsionFree()
        } catch {
            return false
        }
    }
    
    // [-0xd201000000010000]P
    func mulCurveX() throws -> Self {
        try unsafeMultiply(scalar: G1.Curve.x).negated()
    }
    
    // [0xd201000000010000]P
    func mulCurveMinusX() throws -> Self {
        try unsafeMultiply(scalar: G1.Curve.x)
    }
    
    // Checks is the point resides in prime-order subgroup.
    // point.isTorsionFree() should return true for valid points
    // It returns false for shitty points.
    // https://eprint.iacr.org/2021/1130.pdf
    func _isTorsionFree() throws -> Bool {
        // TODO: fix if outcommented below is better, Noble has this comment
        let xP = try mulCurveX() // [x]P
        let u2P = try xP.mulCurveMinusX() // [u2]P
        let _phi = phi()
        return u2P == _phi
        
        // https://eprint.iacr.org/2019/814.pdf
        // (z² − 1)/3
        // const c1 = 0x396c8c005555e1560000000055555555n;
        // const P = this;
        // const S = P.sigma();
        // const Q = S.double();
        // const S2 = S.sigma();
        // // [(z² − 1)/3](2σ(P) − P − σ²(P)) − σ²(P) = O
        // const left = Q.subtract(P).subtract(S2).multiplyUnsafe(c1);
        // const C = left.subtract(S2);
        // return C.isZero();
    }
    
    func _isOnCurve() throws -> Bool {
        let left = try y.pow(n: 2) * z - x.pow(n: 3)
        let right = try G1.b * z.pow(n: 3)
        return (left - right).isZero
    }
}

extension P1 {
    typealias Error = ProjectivePointError
}
