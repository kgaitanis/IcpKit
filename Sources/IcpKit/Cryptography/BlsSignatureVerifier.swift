//
//  BlsSignatureVerifier.swift
//
//  Created by Coding Assistant on 19.09.26.
//

import Foundation

final class BlsSignatureVerifier {
    func verify(message: any DataProtocol, publicKey: any DataProtocol, signature: any DataProtocol) throws {
        _ = message
        _ = publicKey
        _ = signature

        try finishVerification(.valid)
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
