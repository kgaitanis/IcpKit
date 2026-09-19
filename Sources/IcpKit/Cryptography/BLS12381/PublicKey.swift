//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-09-18.
//

import Foundation

public struct PublicKey: GroupElementConveritible, Equatable {
   
    public typealias Group = G1
    
    public let groupElement: G1
   
    public init(groupElement: G1) throws {
        guard !groupElement.isZero else {
            throw Error.invalidPublicKeyAtInfinity
        }
        guard groupElement.subgroupCheck() else {
            throw Error.invalidPublicKeyNotSubgroup
        }
        self.groupElement = groupElement
    }
}

public extension PublicKey {
    
    enum Error: String, Swift.Error, Sendable {
        case invalidPublicKeyAtInfinity
        case invalidPublicKeyNotSubgroup
    }
    
    /// Checks if pairing of public key & hash is equal to pairing of generator & signature.
    /// `e(P, H(m)) == e(G, S)`
    func isValidSignature(
        _ signature: Signature,
        byHashingMessageToCheck messageData: Data
    ) async  -> Bool {
        do {
            return try await _isValidSignature(signature, byHashingMessageToCheck: messageData)
        } catch {
            return false
        }
    }
    
    /// Checks if pairing of public key & hash is equal to pairing of generator & signature.
    /// `e(P, H(m)) == e(G, S)`
    func isValidSignature(
        _ signature: Signature,
        for message: Message
    ) async -> Bool {
        do {
            return try await _isValidSignature(signature, for: message)
        } catch {
            return false
        }
    }
    
    /// Adds a bunch of public key points together.
    /// `pk1 + pk2 + pk3 + ... + pkN = pkA`
    static func aggregate(_ publicKeys: [Self]) throws -> Self {
        guard !publicKeys.isEmpty else {
            throw CannotAggregateEmptyList()
        }
        let aggregatedPoint = publicKeys.map { $0.groupElement.point }.reduce(Group.Point.zero, +)
        return try Self(groupElement: .init(point: aggregatedPoint))
    }
    
    /// Checks if pairing of public keys & hashes are equal to pairing of generator & signature.
    ///
    /// https://ethresear.ch/t/fast-verification-of-multiple-bls-signatures/5407
    /// `e(G, S) = e(G, SUM(n)(Si)) = MUL(n)(e(G, Si))`
    static func isValidSignature(
        _ signature: Signature,
        forMessages messages: [Message],
        publicKeysOfSigners publicKeys: [Self]
    ) async -> Bool {
        do {
            return try await _isValidSignature(
                signature,
                forMessages: messages,
                publicKeysOfSigners: publicKeys
            )
        } catch {
            return false
        }
    }
    
    /// Checks if pairing of public keys & hashes are equal to pairing of generator & signature,
    /// by first doing hashToCurve on each message data.
    ///
    /// https://ethresear.ch/t/fast-verification-of-multiple-bls-signatures/5407
    /// `e(G, S) = e(G, SUM(n)(Si)) = MUL(n)(e(G, Si))`
    static func isValidSignature(
        _ signature: Signature,
        byHashingMessagesToCheck messagesToHash: [Data],
        publicKeysOfSigners publicKeys: [Self]
    ) async throws -> Bool {
        do {
            return try await _isValidSignature(
                signature,
                byHashingMessagesToCheck: messagesToHash,
                publicKeysOfSigners: publicKeys
            )
        } catch {
            return false
        }
    }
}
struct CannotAggregateEmptyList: Error {}

internal extension PublicKey {
    
    func _isValidSignature(
        _ signature: Signature,
        byHashingMessageToCheck messageToHash: Data
    ) async throws -> Bool {
        let message = try await Message(hashing: messageToHash)
        return try await _isValidSignature(signature, for: message)
    }
    
    func _isValidSignature(
        _ signature: Signature,
        for message: Message
    ) async throws -> Bool {
        let P = groupElement
        let G = G1.generator
        let S = signature.groupElement
        let Hm = message.groupElement
        
        // Instead of doing 2 exponentiations, we use property of billinear maps
        // and do one exp after multiplying 2 points.
        let ePHm = try BLS.pairing(g1: P.negated(), g2: Hm, withFinalExponent: false)
        let eGS = try BLS.pairing(g1: G, g2: S, withFinalExponent: false)
        let exp = try (eGS * ePHm).finalExponentiate()
        let isValid = exp == Fp12.one
        return isValid
    }
    
    static func _isValidSignature(
        _ signature: Signature,
        byHashingMessagesToCheck messagesToHash: [Data],
        publicKeysOfSigners publicKeys: [Self]
    ) async throws -> Bool {
        let messages = try await messagesToHash.asyncMap {
            try await Message(hashing: $0)
        }
        return try await _isValidSignature(
            signature,
            forMessages: messages,
            publicKeysOfSigners: publicKeys
        )
    }
    
    static func _isValidSignature(
        _ signature: Signature,
        forMessages messages: [Message],
        publicKeysOfSigners publicKeys: [Self]
    ) async throws -> Bool {
        guard !messages.isEmpty else {
            throw BatchValidateSignatureError.messagesCannotBeEmpty
        }
        guard publicKeys.count == messages.count else {
            throw BatchValidateSignatureError.publicKeysAndMessagesMustHaveSameLength
        }
        var paired = [Fp12]()
        for message in messages {
            let groupPublicKey = try messages.enumerated().reduce(into: G1.zero) { (acc, tuple) in
                let index = tuple.offset
                if message == tuple.element {
                    try acc += publicKeys[index].groupElement
                }
            }
            let pairing = try BLS.pairing(g1: groupPublicKey, g2: message.groupElement, withFinalExponent: false)
            paired.append(pairing)
        }
        let pairing = try BLS.pairing(g1: G1.generator.negated(), g2: signature.groupElement, withFinalExponent: false)
        paired.append(pairing)
        let product = paired.reduce(Fp12.one, *)
        let exponentiated = try product.finalExponentiate()
        let isValid = exponentiated == .one
        return isValid
    }
}

enum BatchValidateSignatureError: Error {
    case messagesCannotBeEmpty
    case publicKeysAndMessagesMustHaveSameLength
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
