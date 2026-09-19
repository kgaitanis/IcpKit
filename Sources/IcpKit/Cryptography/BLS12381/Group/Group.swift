//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-02.
//

import Foundation
import BigInt

public protocol EllipticCurve where Group.Curve == Self {
    associatedtype Group: FiniteGroup
    /// The generator point of a group this projective point is an element of.
    static var generator: Group { get }
    static var modulus: BigInt { get }
    static var order: BigInt { get }
    static var cofactor: BigInt { get }
}
public extension EllipticCurve {
    static var maxBits: Int { Self.order.bitWidthIgnoreSign }
}


public extension EllipticCurve {
    /// Modulus, short name.
    static var P: BigInt { modulus }
    /// Order, short name.
    static var r: BigInt { order }
    /// Cofactor, short name.
    static var b: BigInt { order }
}

public protocol DataSerializable {
    func toData(compress: Bool) -> Data
}

public extension DataSerializable {
    func toHex(
        compress: Bool = true,
        hexEncoding: Data.HexEncodingOptions = []
    ) -> String {
        toData(compress: compress).hex(options: hexEncoding)
    }
}

public protocol DataDeserializable {
    init(bytes: some ContiguousBytes) throws
    init(uncompressedData: Data) throws
    init(compressedData: Data) throws
}

public protocol FiniteGroup:
    Equatable,
    CustomToStringConvertible,
    ThrowingSignedNumeric,
    ThrowingAdditiveArtithmetic,
    ThrowingMultipliableByScalarArtithmetic,
    DataSerializable,
    DataDeserializable
where Curve.Group == Self {
    associatedtype Curve: EllipticCurve
    associatedtype Point: ProjectivePoint
    
    static var identity: Self { get }
    
    var point: Point { get }
    init(x: Point.F, y: Point.F, z: Point.F) throws
    var isZero: Bool { get }
    init(point: Point) throws
    
    static var compressedDataByteCount: Int { get }
    static var uncompressedDataByteCount: Int { get }
}

public extension FiniteGroup {
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
    func subgroupCheck() -> Bool {
        do {
            return try point.unsafeMultiply(scalar: Curve.order) == .zero
        } catch {
            return false
        }
    }
}
private extension FiniteGroup {
    static func op(_ lhs: Self, _ rhs: Self, _ operation: (Point, Point) throws -> Point) throws -> Self {
        try .init(point: operation(lhs.point, rhs.point))
    }
}


public extension FiniteGroup {
    static var identity: Self { try! Self(x: .one, y: .one, z: .zero) }
    static var zero: Self { try! Self.init(point: .zero) }
    
    init(bytes: some ContiguousBytes) throws {
        let data = bytes.withUnsafeBytes { Data($0) }
        if data.count == Self.compressedDataByteCount {
            try self.init(compressedData: data)
        } else if data.count == Self.uncompressedDataByteCount {
            try self.init(uncompressedData: data)
        } else {
            throw ProjectivePointError.invalidByteCount(
                expectedCompressed: Self.compressedDataByteCount,
                orUncompressed: Self.uncompressedDataByteCount,
                butGot: data.count
            )
        }
    }
    
    var isZero: Bool { point.isZero }
}
public extension FiniteGroup {
    var x: Point.F { point.x }
    var y: Point.F { point.y }
    var z: Point.F { point.z }
    
    func toString(radix: Int, pad: Bool) -> String {
        point.toString(radix: radix, pad: pad)
    }
}
