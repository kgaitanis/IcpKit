//
//  File.swift
//
//
//  Created by Alexander Cyon on 2022-09-18.
//

import BigInt
import Foundation

/// An algebraic field.
public protocol Field:
    Equatable,
    MultipliableByScalarArtithmetic,
    Numeric_,
    SignedNumeric_,
    DivisionArithmetic,
    DivisibleByScalarArithmetic,
    CustomToStringConvertible
{
    static var one: Self { get }
    
    /// Multiplicative inverse of a nonzero element.
    func inverted() throws -> Self

    func squared() throws -> Self
    func pow(n: BigInt) throws -> Self

}
