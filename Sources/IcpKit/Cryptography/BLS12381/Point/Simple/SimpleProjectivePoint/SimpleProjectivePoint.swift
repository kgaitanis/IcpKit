//
//  SimpleProjectivePoint.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation

struct SimpleProjectivePoint<F: Field>: Sendable {
    let x: F
    let y: F
    let z: F
}

typealias ProjectivePointFp2 = SimpleProjectivePoint<Fp2>
