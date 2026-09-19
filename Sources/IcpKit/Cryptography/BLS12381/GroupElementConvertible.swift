//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-28.
//

import Foundation

public protocol GroupElementConveritible: CustomToStringConvertible, DataSerializable, DataDeserializable {
    associatedtype Group: FiniteGroup
    var groupElement: Group { get }
    init(groupElement: Group) throws
}

public extension GroupElementConveritible {
    func toString(radix: Int, pad: Bool) -> String {
        groupElement.toString(radix: radix, pad: pad)
    }
}
public extension GroupElementConveritible {
    static func ==(lhs: Self, rhs: Group) -> Bool {
        lhs.groupElement == rhs
    }
    static func ==(lhs: Group, rhs: Self) -> Bool {
        lhs == rhs.groupElement
    }
}

public extension GroupElementConveritible {

    init(compressedData data: Data) throws {
        try self.init(groupElement: .init(compressedData: data))
    }

    init(uncompressedData data: Data) throws {
        try self.init(groupElement: .init(uncompressedData: data))
    }
    
    init(bytes: some ContiguousBytes) throws {
        let data = bytes.withUnsafeBytes { Data($0) }
        if data.count == G2.compressedDataByteCount {
            try self.init(compressedData: data)
        } else if data.count == G2.uncompressedDataByteCount {
            try self.init(uncompressedData: data)
        } else {
            throw BadByteCount()
        }
    }
    
    func toData(compress: Bool = true) -> Data {
        groupElement.toData(compress: compress)
    }
}

struct BadByteCount: Error {}
