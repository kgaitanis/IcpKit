//
//  BitArray.swift
//
//  Created by Konstantinos Gaitanis on 19.09.26.
//

import BigInt

struct BitArray: Collection {
    typealias Index = Int

    private let bits: [Bool]

    var startIndex: Int { bits.startIndex }
    var endIndex: Int { bits.endIndex }

    subscript(position: Int) -> Bool {
        bits[position]
    }

    func index(after i: Int) -> Int {
        bits.index(after: i)
    }

    init(bitPattern value: BigInt) {
        guard value > 0 else {
            bits = [false]
            return
        }

        bits = (0..<value.bitWidthIgnoreSign).map { bitIndex in
            ((value >> bitIndex) & 1) == 1
        }
    }

    init(bitPattern value: UInt64) {
        guard value > 0 else {
            bits = [false]
            return
        }

        let bitWidth = value.bitWidth - value.leadingZeroBitCount
        bits = (0..<bitWidth).map { bitIndex in
            ((value >> UInt64(bitIndex)) & 1) == 1
        }
    }
}
