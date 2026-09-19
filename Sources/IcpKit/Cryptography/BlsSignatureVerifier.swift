//
//  BlsSignatureVerifier.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import Foundation

final class BlsSignatureVerifier {
    func verify(message: any DataProtocol, publicKey: any DataProtocol, signature: any DataProtocol) throws {
        do {
            let signaturePoint = try G1(compressedData: Data(signature))
            let publicKeyPoint = try G2(compressedData: Data(publicKey))
            let hashedMessagePoint = try BLS.icpHashToG1(message: Data(message))

            let generatorSignaturePairing = try BLS.pairing(
                g1: signaturePoint.negated(),
                g2: G2.generator,
                withFinalExponent: false
            )
            let publicKeyMessagePairing = try BLS.pairing(
                g1: hashedMessagePoint,
                g2: publicKeyPoint,
                withFinalExponent: false
            )
            let result = try (generatorSignaturePairing * publicKeyMessagePairing).finalExponentiate()
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
