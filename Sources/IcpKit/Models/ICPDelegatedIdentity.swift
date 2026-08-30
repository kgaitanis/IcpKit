//
//  ICPDelegatedIdentity.swift
//

import Foundation
import CryptoKit
@preconcurrency import PotentASN1

/// An identity that has been delegated the authority to authenticate as a different principal.
/// Note: This type validates the delegation chain during initialization.
public final class ICPDelegatedIdentity: ICPSigningPrincipal, ICPDelegationProvider, ICPDerPublicKeyProvider {
    public enum Error: Swift.Error {
        case invalidDerPublicKey
        case unsupportedAlgorithm
        case invalidSignature
        case brokenChain
        case signingKeyMismatch
    }

    private enum PublicKeyAlgorithm {
        case secp256k1
        case p256
        case ed25519
    }

    private struct ParsedPublicKey {
        let algorithm: PublicKeyAlgorithm
        let keyBytes: Data
    }

    public let principal: ICPPrincipal
    /// For this type, `rawPublicKey` is the DER-encoded public key.
    public let rawPublicKey: Data
    public let publicKeyDer: Data
    public var delegationChain: [ICPSignedDelegation] {
        let baseChain = (signingIdentity as? ICPDelegationProvider)?.delegationChain ?? []
        return baseChain + chain
    }

    private let signingIdentity: ICPSigningPrincipal
    private let chain: [ICPSignedDelegation]

    /// Creates a delegated identity that signs using `to`, for the principal corresponding to `fromPublicKeyDer`.
    ///
    /// - Parameters:
    ///   - fromPublicKeyDer: DER-encoded public key of the delegated-from principal.
    ///   - to: The signing identity used to sign requests.
    ///   - chain: Delegations connecting `fromPublicKeyDer` to `to.publicKey`, in order.
    public init(fromPublicKeyDer: Data, to: ICPSigningPrincipal, chain: [ICPSignedDelegation]) throws {
        try ICPDelegatedIdentity.validateChain(fromPublicKeyDer: fromPublicKeyDer, to: to, chain: chain)
        self.publicKeyDer = fromPublicKeyDer
        self.rawPublicKey = fromPublicKeyDer
        self.principal = ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: fromPublicKeyDer)
        self.signingIdentity = to
        self.chain = chain
    }

    /// Creates a delegated identity without validating the delegation chain.
    public static func unchecked(fromPublicKeyDer: Data, to: ICPSigningPrincipal, chain: [ICPSignedDelegation]) -> ICPDelegatedIdentity {
        ICPDelegatedIdentity(uncheckedFromPublicKeyDer: fromPublicKeyDer, to: to, chain: chain)
    }

    private init(uncheckedFromPublicKeyDer: Data, to: ICPSigningPrincipal, chain: [ICPSignedDelegation]) {
        self.publicKeyDer = uncheckedFromPublicKeyDer
        self.rawPublicKey = uncheckedFromPublicKeyDer
        self.principal = ICPCryptography.selfAuthenticatingPrincipal(derPublicKey: uncheckedFromPublicKeyDer)
        self.signingIdentity = to
        self.chain = chain
    }

    public func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data {
        try await signingIdentity.sign(message, domain: domain)
    }
}

private extension ICPDelegatedIdentity {
    static let ecPublicKeyOid: [UInt64] = [1, 2, 840, 10045, 2, 1]
    static let secp256k1Oid: [UInt64] = [1, 3, 132, 0, 10]
    static let prime256v1Oid: [UInt64] = [1, 2, 840, 10045, 3, 1, 7]
    static let ed25519Oid: [UInt64] = [1, 3, 101, 112]

    static func validateChain(fromPublicKeyDer: Data, to: ICPSigningPrincipal, chain: [ICPSignedDelegation]) throws {
        var lastVerifiedDer = fromPublicKeyDer
        for signed in chain {
            let parsedKey = try parseDerPublicKey(lastVerifiedDer)
            let message = try signed.delegation.signable()
            try verify(signature: signed.signature, message: message, with: parsedKey)
            lastVerifiedDer = signed.delegation.pubkey
        }

        let signingKeyDer: Data
        if let derProvider = to as? ICPDerPublicKeyProvider {
            signingKeyDer = derProvider.publicKeyDer
        } else {
            signingKeyDer = try ICPCryptography.der(uncompressedEcPublicKey: to.rawPublicKey)
        }

        guard lastVerifiedDer == signingKeyDer else {
            throw Error.signingKeyMismatch
        }
    }

    private static func parseDerPublicKey(_ der: Data) throws -> ParsedPublicKey {
        let values = try ASN1Serialization.asn1(fromDER: der)
        guard let value = values.first,
              case .sequence(let topLevel) = value,
              topLevel.count >= 2,
              case .sequence(let algorithmItems) = topLevel[0].absolute,
              let bitString = topLevel[1].bitStringValue else {
            throw Error.invalidDerPublicKey
        }

        guard let algorithmOid = algorithmItems.first?.objectIdentifierValue?.fields else {
            throw Error.invalidDerPublicKey
        }

        if algorithmOid == ecPublicKeyOid {
            guard algorithmItems.count >= 2,
                  let curveOid = algorithmItems[1].objectIdentifierValue?.fields else {
                throw Error.invalidDerPublicKey
            }
            if curveOid == secp256k1Oid {
                return ParsedPublicKey(algorithm: .secp256k1, keyBytes: bitString.bytes)
            }
            if curveOid == prime256v1Oid {
                return ParsedPublicKey(algorithm: .p256, keyBytes: bitString.bytes)
            }
            throw Error.unsupportedAlgorithm
        }

        if algorithmOid == ed25519Oid {
            return ParsedPublicKey(algorithm: .ed25519, keyBytes: bitString.bytes)
        }

        throw Error.unsupportedAlgorithm
    }

    private static func verify(signature: Data, message: Data, with key: ParsedPublicKey) throws {
        switch key.algorithm {
        case .secp256k1:
            let isValid = try ICPCryptography.verifySecp256k1(
                signatureDER: signature,
                message: message,
                publicKeyUncompressed: key.keyBytes
            )
            guard isValid else { throw Error.invalidSignature }

        case .p256:
            let publicKey = try P256.Signing.PublicKey(x963Representation: key.keyBytes)
            let signature = try P256.Signing.ECDSASignature(derRepresentation: signature)
            guard publicKey.isValidSignature(signature, for: message) else {
                throw Error.invalidSignature
            }

        case .ed25519:
            let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: key.keyBytes)
            guard publicKey.isValidSignature(signature, for: message) else {
                throw Error.invalidSignature
            }
        }
    }
}
