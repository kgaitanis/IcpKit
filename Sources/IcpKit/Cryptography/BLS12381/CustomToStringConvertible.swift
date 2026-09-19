//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//

import Foundation

public protocol CustomToStringConvertible:
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    func toString(radix: Int, pad: Bool) -> String
}

public extension CustomToStringConvertible {
    
    var description: String {
//        toDecimalString(pad: false)
        toHexString(pad: true)
    }
    
    func toDecimalString(pad: Bool = false) -> String {
        toString(radix: 10, pad: pad)
    }
    
    func toHexString(pad: Bool = true) -> String {
        toString(radix: 16, pad: pad)
    }
    
    var debugDescription: String {
        toHexString(pad: true)
    }
    
}
