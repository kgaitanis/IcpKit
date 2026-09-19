//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-03.
//

import Foundation

struct Message: Equatable, GroupElementConveritible {
    typealias Group = G2
    let groupElement: G2
    
    init(groupElement: G2) {
        self.groupElement = groupElement
    }
}

extension Message {
    init(hashing data: Data) async throws {
        try await self.init(hashing: data, domainSeperationTag: .g2Basic)
    }
}


extension Message {
    init(hashing data: Data, domainSeperationTag: DomainSeperationTag) async throws {
        let p2 = try await P2.hashToCurve(
            message: data,
            hashToFieldConfig: .init(domainSeperationTag: domainSeperationTag)
        )
        try self.init(groupElement: .init(point: p2))
    }
}
