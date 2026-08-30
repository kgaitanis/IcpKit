//
//  ICPRequestEnvelope.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation

public struct ICPRequestEnvelope: Encodable {
    public let content: ICPRequestContent
    public let sender_pubkey: Data?
    public let sender_sig: Data?
    public let sender_delegation: [ICPSignedDelegation]?
    
    public init(content: ICPRequestContent, sender_pubkey: Data, sender_sig: Data, sender_delegation: [ICPSignedDelegation]? = nil) {
        self.content = content
        self.sender_pubkey = sender_pubkey
        self.sender_sig = sender_sig
        self.sender_delegation = sender_delegation
    }
    
    public init(content: ICPRequestContent) {
        self.content = content
        self.sender_pubkey = nil
        self.sender_sig = nil
        self.sender_delegation = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        enum Keys: String, CodingKey { case content, sender_pubkey, sender_sig, sender_delegation }
        var container = encoder.container(keyedBy: Keys.self)
        if let readStateContent = content as? ReadStateRequestContent {
            try container.encode(readStateContent, forKey: Keys.content)
        } else if let callContent = content as? CallRequestContent {
            try container.encode(callContent, forKey: Keys.content)
        } else {
            throw ICPRequestEnvelopeEncodingError.invalidContent
        }
        try container.encode(sender_pubkey, forKey: Keys.sender_pubkey)
        try container.encode(sender_sig, forKey: Keys.sender_sig)
        try container.encode(sender_delegation, forKey: Keys.sender_delegation)
    }
    
    private enum ICPRequestEnvelopeEncodingError: Error {
        case invalidContent
    }
}
