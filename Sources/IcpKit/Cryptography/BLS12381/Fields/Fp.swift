//
//  Fp.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//  Modified by Konstantinos Gaitanis on 2026-09-19.
//

import Foundation

/// Finite field over `p`.
struct Fp: FiniteField, Sendable {
    private let storage: MontgomeryFp

    var isOdd: Bool {
        storage.isOdd
    }

    var isLexicographicallyLargest: Bool {
        storage.isLexicographicallyLargest
    }

    func isGreaterThan(_ other: Self) -> Bool {
        storage.isGreaterThan(other.storage)
    }

    init(_ value: Int) {
        precondition(value >= 0)
        self.storage = MontgomeryFp(canonicalLimbs: (UInt64(value), 0, 0, 0, 0, 0))
    }

    init(hex: String) {
        self.storage = MontgomeryFp(hex: hex)
    }

    init(canonicalBytes: Data) throws {
        self.storage = try MontgomeryFp(canonicalBytes: canonicalBytes)
    }

    init(storage: MontgomeryFp) {
        self.storage = storage
    }
}

extension Fp {
    static let zero = Self(0)
    static let one = Self(1)
    
    func negated() -> Self {
        Self(storage: storage.negated())
    }
    
    func inverted() throws -> Self {
        try Self(storage: storage.inverted())
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(storage: lhs.storage + rhs.storage)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(storage: lhs.storage - rhs.storage)
    }
    
    static func * (lhs: Self, rhs: Self) -> Self {
        Self(storage: lhs.storage * rhs.storage)
    }
    
    static func / (lhs: Self, rhs: Self) throws -> Self {
        try Self(storage: lhs.storage / rhs.storage)
    }
    
    func squared() throws -> Self {
        Self(storage: storage.squared())
    }
    
    func pow(exponent: UInt64) throws -> Self {
        Self(storage: storage.pow(exponent: exponent))
    }
    
    // square root computation for p ≡ 3 (mod 4)
    // a^((p-3)/4)) ≡ 1/√a (mod p)
    // √a ≡ a * 1/√a ≡ a^((p+1)/4) (mod p)
    // It's possible to unwrap the exponentiation, but (P+1)/4 has 228 1's out of 379 bits.
    // https://eprint.iacr.org/2012/685.pdf
    func sqrt() -> Self? {
        storage.sqrt().map(Self.init(storage:))
    }
}
