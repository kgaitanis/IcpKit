//
//  BLSCompatibility.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import BigInt
import Foundation

extension BigInt: @unchecked Sendable {}

extension Fp: @unchecked Sendable {}
extension Fp2: @unchecked Sendable {}
extension Fp6: @unchecked Sendable {}
extension Fp12: @unchecked Sendable {}
extension P1: @unchecked Sendable {}
extension P2: @unchecked Sendable {}
extension G1: @unchecked Sendable {}
extension G2: @unchecked Sendable {}
extension DomainSeperationTag: @unchecked Sendable {}
extension HashToFieldConfig: @unchecked Sendable {}

extension Data {
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    func hex(options: HexEncodingOptions = []) -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}

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
