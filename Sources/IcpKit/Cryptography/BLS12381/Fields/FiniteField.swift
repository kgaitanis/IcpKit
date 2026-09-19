//
//  FiniteField.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation
import BigInt

/// A Finite algebraic field.
protocol FiniteField: Field {
    static var order: BigInt { get }
}
extension FiniteField {
    var order: BigInt { Self.order }
}
