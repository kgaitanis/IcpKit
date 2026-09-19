//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-27.
//

import Foundation

struct SimpleProjectivePoint<F: Field> {
    let x: F
    let y: F
    let z: F
}

typealias ProjectivePointFp2 = SimpleProjectivePoint<Fp2>
