//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-03.
//

import Foundation

public struct Signature: Equatable, GroupElementConveritible {
    public typealias Group = G2
    public let groupElement: G2
    
    public init(groupElement: G2) {
        self.groupElement = groupElement
    }
}

public extension Signature {
    
    /// Adds a bunch of signature points together.
    /// `s1 + s2 + s3 + ... + sN = sA`
    static func aggregate(_ signatures: [Self]) throws -> Self {
        guard !signatures.isEmpty else {
            throw CannotAggregateEmptyList()
        }
        let aggregatedPoint = signatures.map { $0.groupElement.point }.reduce(Group.Point.zero, +)
        return try Self(groupElement: .init(point: aggregatedPoint))
    }
}
