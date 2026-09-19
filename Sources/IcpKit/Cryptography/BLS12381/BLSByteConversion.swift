//
//  BLSByteConversion.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import BigInt
import Foundation

/// Octet stream to integer.
///
/// `BigInt(data)` interprets bytes differently here; BLS encodings use unsigned
/// big-endian octet strings.
func os2ip(_ data: Data) -> BigInt {
    BigInt(sign: .plus, magnitude: BigUInt(data))
}

func i2osp(_ value: Int, _ length: Int) -> Data {
    let preconditionFailureMessage = "Bad I2OSP call, value: \(value), length: \(length)"
    precondition(value >= 0, preconditionFailureMessage)

    var value = value
    var result = Data(repeating: 0x00, count: length)
    for i in 0..<length {
        result[length - 1 - i] = UInt8(value & 0xff)
        value >>= 8
    }
    return result
}
