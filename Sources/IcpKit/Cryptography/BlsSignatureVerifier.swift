//
//  BlsSignatureVerifier.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import Foundation
import os

final class BlsSignatureVerifier {
    private static let generatorPairingPrecomputes = try! G2.generator.point.pairingPrecomputes()
    private static let publicKeyCache = PublicKeyPairingCache(maximumEntryCount: 8)

    func verify(message: any DataProtocol, publicKey: any DataProtocol, signature: any DataProtocol) throws {
        do {
            let publicKeyData = Data(publicKey)
            let signaturePoint = try G1(compressedData: Data(signature))
            let hashedMessagePoint = try BLS.icpHashToG1(message: Data(message))

            let signatureGeneratorTerm = try BLS.pairingTerm(
                g1: signaturePoint.negated(),
                ell: Self.generatorPairingPrecomputes
            )
            let messagePublicKeyTerm = try BLS.pairingTerm(
                g1: hashedMessagePoint,
                ell: Self.publicKeyCache.pairingPrecomputes(for: publicKeyData)
            )
            let result = try BLS.millerLoop(terms: [
                signatureGeneratorTerm,
                messagePublicKeyTerm
            ]).finalExponentiate()
            try finishVerification(result == .one ? .valid : .invalid)
        } catch {
            throw ICPStateCertificateError.invalidSignature
        }
    }

    private func finishVerification(_ result: VerificationResult) throws {
        switch result {
        case .valid:
            return
        case .invalid:
            throw ICPStateCertificateError.invalidSignature
        }
    }

    private enum VerificationResult {
        case valid
        case invalid
    }
}

private final class PublicKeyPairingCache: Sendable {
    private struct State: Sendable {
        var entries: [Data: [ProjectivePointFp2]] = [:]
        var insertionOrder: [Data] = []
    }

    private let maximumEntryCount: Int
    private let state = OSAllocatedUnfairLock(initialState: State())

    init(maximumEntryCount: Int) {
        self.maximumEntryCount = maximumEntryCount
    }

    func pairingPrecomputes(for publicKeyData: Data) throws -> [ProjectivePointFp2] {
        if let cached = cachedPairingPrecomputes(for: publicKeyData) {
            return cached
        }

        let publicKeyPoint = try G2(compressedData: publicKeyData)
        guard !publicKeyPoint.isZero else {
            throw NoPairingExistsAtPointOfInfinity()
        }

        let precomputes = try publicKeyPoint.point.pairingPrecomputes()
        cache(precomputes, for: publicKeyData)
        return precomputes
    }

    private func cachedPairingPrecomputes(for publicKeyData: Data) -> [ProjectivePointFp2]? {
        state.withLock { state in
            state.entries[publicKeyData]
        }
    }

    private func cache(_ precomputes: [ProjectivePointFp2], for publicKeyData: Data) {
        state.withLock { state in
            if state.entries[publicKeyData] != nil {
                state.entries[publicKeyData] = precomputes
                return
            }

            state.entries[publicKeyData] = precomputes
            state.insertionOrder.append(publicKeyData)

            while state.insertionOrder.count > maximumEntryCount {
                let removedKey = state.insertionOrder.removeFirst()
                state.entries[removedKey] = nil
            }
            return
        }
    }
}

private extension BLS {
    static func pairingTerm(g1: G1, ell: [ProjectivePointFp2]) throws -> (ell: [ProjectivePointFp2], g1: AffinePoint<Fp>) {
        guard !g1.isZero else {
            throw NoPairingExistsAtPointOfInfinity()
        }
        return try (
            ell: ell,
            g1: g1.point.toAffine()
        )
    }
}
