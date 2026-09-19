//
//  Group.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

protocol EllipticCurve where Group.Curve == Self {
    associatedtype Group: FiniteGroup
    /// The generator point of a group this projective point is an element of.
    static var generator: Group { get }
    static var modulus: BigInt { get }
    static var order: BigInt { get }
}


extension EllipticCurve {
    /// Modulus, short name.
    static var P: BigInt { modulus }
}

protocol FiniteGroup:
    Equatable,
    ThrowingSignedNumeric,
    ThrowingAdditiveArtithmetic,
    ThrowingMultipliableByScalarArtithmetic
where Curve.Group == Self {
    associatedtype Curve: EllipticCurve
    associatedtype Point: ProjectivePoint
    
    static var identity: Self { get }
    
    var point: Point { get }
    init(x: Point.F, y: Point.F, z: Point.F) throws
    var isZero: Bool { get }
    init(point: Point) throws
    
    static var compressedDataByteCount: Int { get }
    init(compressedData: Data) throws
}

extension FiniteGroup {
    static var generator: Self { Self.Curve.generator }
    static func + (lhs: Self, rhs: Self) throws -> Self {
        try op(lhs, rhs, +)
    }
    static func * (lhs: Self, scalar: BigInt) throws -> Self {
        try self.init(point: lhs.point * scalar)
    }
    func negated() throws -> Self {
        try Self(point: point.negated())
    }
}
private extension FiniteGroup {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Point, Point) throws -> Point) throws -> Self {
        try .init(point: operation(lhs.point, rhs.point))
    }
}


extension FiniteGroup {
    static var identity: Self { try! Self(x: .one, y: .one, z: .zero) }
    static var zero: Self { try! Self.init(point: .zero) }

    var isZero: Bool { point.isZero }
}
extension FiniteGroup {
    var x: Point.F { point.x }
    var y: Point.F { point.y }
    var z: Point.F { point.z }
}
