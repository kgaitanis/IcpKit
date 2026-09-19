//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation

public struct AffinePoint<F: Field>: Equatable {
    public let x: F
    public let y: F
    public init(x: F, y: F) {
        self.x = x
        self.y = y
    }
}

public extension AffinePoint {
    func toString(radix: Int = 16, pad: Bool = false) -> String {
        """
        Affine(
            x: \(x.toString(radix: radix, pad: pad)),
            y: \(y.toString(radix: radix, pad: pad)
        )
        """
    }
}

public extension AffinePoint where F == Fp2 {
    // Ψ(P) endomorphism
    func psi() -> Self {
        // Untwist Fp2->Fp12 && frobenius(1) && twist back
        let tmpX = (BLS.wsqInv * x).frobeniusMap(power: 1) * BLS.wsq
        let x2 = tmpX.c0.c0
        
        let tmpY = (BLS.wcuInv * y).frobeniusMap(power: 1) * BLS.wcu
        let y2 = tmpY.c0.c0
        
        return .init(x: x2, y: y2)
    }
    
    // Ψ²(P) endomorphism
    func psi2() -> Self {
        .init(
            x: x * psi2C1,
            y: y.negated()
        )
    }
}

/// `1 / F2(2)^((p-1)/3) in GF(p²)`
private let psi2C1 = Frobenius.aaac

