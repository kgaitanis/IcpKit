//
//  Field.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation

/// An algebraic field.
protocol Field:
    Equatable,
    Numeric_,
    SignedNumeric_,
    DivisionArithmetic,
    Sendable
{
    static var one: Self { get }
    
    /// Multiplicative inverse of a nonzero element.
    func inverted() throws -> Self

    func squared() throws -> Self
    func pow(exponent: UInt64) throws -> Self

}

extension Field {
    static func * (lhs: Self, rhs: Int) -> Self {
        guard rhs != 0 else { return .zero }
        if rhs < 0 {
            return (lhs * -rhs).negated()
        }

        var result = Self.zero
        var base = lhs
        var scalar = rhs
        while scalar > 0 {
            if (scalar & 1) == 1 {
                result += base
            }
            base += base
            scalar >>= 1
        }
        return result
    }

    static func * (lhs: Int, rhs: Self) -> Self {
        rhs * lhs
    }

    static func / (lhs: Self, rhs: Int) throws -> Self {
        try lhs / (.one * rhs)
    }
}
