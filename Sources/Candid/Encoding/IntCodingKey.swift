//
//  IntCodingKey.swift
//  
//
//  Created by Konstantinos Gaitanis on 25.07.24.
//

import Foundation

internal struct IntCodingKey: CodingKey {
    var stringValue: String { return String(intValue!) }
    let intValue: Int?

    init?(stringValue: String) { return nil }
    init(intValue: Int) { self.intValue = intValue }
}
