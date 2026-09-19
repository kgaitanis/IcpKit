//
//  BLSCompatibility.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import BigInt
import Foundation

extension Fp: @unchecked Sendable {}
extension Fp2: @unchecked Sendable {}
extension Fp6: @unchecked Sendable {}
extension Fp12: @unchecked Sendable {}
extension P1: @unchecked Sendable {}
extension P2: @unchecked Sendable {}
extension G1: @unchecked Sendable {}
extension G2: @unchecked Sendable {}
extension HashToFieldConfig: @unchecked Sendable {}

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
}

extension Array {
    func chunks(ofCount chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: count, by: chunkSize).map { startIndex in
            Array(self[startIndex..<Swift.min(startIndex + chunkSize, count)])
        }
    }
}
