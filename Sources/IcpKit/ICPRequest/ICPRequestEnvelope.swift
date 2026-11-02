import Foundation

/// Request content and optional authentication fields encoded for the ICP HTTP interface.
public struct ICPRequestEnvelope: Encodable {
    /// The call, query, or read-state content carried by the envelope.
    public let content: ICPRequestContent
    /// The sender's root public key in DER form, or `nil` for an anonymous request.
    public let sender_pubkey: Data?
    /// The request signature from the final signing key, or `nil` for an anonymous request.
    public let sender_sig: Data?
    /// Root-to-leaf signed delegations; omitted from the encoded envelope when empty.
    public let sender_delegation: [ICPSignedDelegation]

    /// Stores signed request fields without validating the signature or delegation chain.
    ///
    /// - Parameters:
    ///   - content: The request content that was signed.
    ///   - sender_pubkey: The root public key as DER SubjectPublicKeyInfo bytes.
    ///   - sender_sig: The signature over the request ID with the `ic-request` domain separator.
    ///   - sender_delegation: Root-to-leaf delegations, or an empty array for a direct signer.
    public init(content: ICPRequestContent, sender_pubkey: Data, sender_sig: Data, sender_delegation: [ICPSignedDelegation] = []) {
        self.content = content
        self.sender_pubkey = sender_pubkey
        self.sender_sig = sender_sig
        self.sender_delegation = sender_delegation
    }

    /// Creates an anonymous envelope without authentication fields.
    ///
    /// - Parameter content: The request content to send anonymously.
    public init(content: ICPRequestContent) {
        self.content = content
        self.sender_pubkey = nil
        self.sender_sig = nil
        self.sender_delegation = []
    }

    /// Encodes request content, omitting absent authentication fields and empty delegations.
    ///
    /// - Parameter encoder: The encoder receiving the wire-format fields.
    /// - Throws: An error if the content is not a supported call or read-state content type,
    ///   or if the encoder fails.
    public func encode(to encoder: Encoder) throws {
        enum Keys: String, CodingKey { case content, sender_pubkey, sender_sig, sender_delegation }
        var container = encoder.container(keyedBy: Keys.self)
        if let readStateContent = content as? ReadStateRequestContent {
            try container.encode(readStateContent, forKey: .content)
        } else if let callContent = content as? CallRequestContent {
            try container.encode(callContent, forKey: .content)
        } else {
            throw ICPRequestEnvelopeEncodingError.invalidContent
        }
        try container.encodeIfPresent(sender_pubkey, forKey: .sender_pubkey)
        try container.encodeIfPresent(sender_sig, forKey: .sender_sig)
        if !sender_delegation.isEmpty {
            try container.encode(sender_delegation, forKey: .sender_delegation)
        }
    }

    private enum ICPRequestEnvelopeEncodingError: Error {
        case invalidContent
    }
}
