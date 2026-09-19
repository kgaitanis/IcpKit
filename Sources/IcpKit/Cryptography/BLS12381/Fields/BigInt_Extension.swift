//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-20.
//

import Foundation
import BigInt

// MARK: CustomDebugStringConvertible
extension BigInt: CustomDebugStringConvertible {}
public extension BigInt {
    
    func toDecimalString(pad: Pad? = nil) -> String {
        toString(radix: 10, pad: pad)
    }
    
    func toHexString(pad: Pad? = .toEvenCount()) -> String {
        toString(radix: 16, pad: pad)
    }
    
    var debugDescription: String {
        toHexString()
    }
    
    func toString(radix: Int, pad: Pad? = nil) -> String {
        let s = String(self, radix: radix)
        guard let pad else { return s }
        
        switch pad {
        case .toLength(let padToLength, let padChar):
            let padAmount = padToLength - s.count
            if padAmount <= 0 {
                return s
            }
            return String(repeating: padChar, count: padAmount) + s
        case .toEvenCount(let padChar):
            if s.count.isMultiple(of: 2) {
                return s
            }
            return padChar + s
        }
        
       
    }
}
public enum Pad {
    case toEvenCount(with: String = "0")
    case toLength(Int, with: String = "0")
}
