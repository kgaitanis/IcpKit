//
//  UInt+Bytes.swift
//
//  Created by Konstantinos Gaitanis on 26.04.23.
//

import Foundation
import BigInt

public extension BinaryInteger {
    /// Little-endian = Least significant byte first
    var bytes: Data {
        return Data(withUnsafeBytes(of: self, Array.init))
    }
    
    /// from little-endian representation
    static func from(_ data: any DataProtocol) -> Self {
        return Data(data).withUnsafeBytes { $0.load(as: Self.self) }
    }
}

public extension FixedWidthInteger {
    /// Big-endian = Most significant byte first
    var bigEndianBytes: Data {
        return bigEndian.bytes
    }
}

public extension BinaryFloatingPoint {
    /// IEEE754 with little-endian
    var bytes: Data { Data(withUnsafeBytes(of: self, Array.init)) }
    
    static func from(_ data: Data) -> Self {
        return data.withUnsafeBytes { $0.load(as: Self.self) }
    }
}

public extension Data {
    init<T>(from value: T) {
        self = withUnsafePointer(to: value) { (ptr: UnsafePointer<T>) -> Data in
            Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
    
}
