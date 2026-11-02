//
//  ICPStateCertificate+Signature.swift
//
//  Created by Konstantinos Gaitanis on 12.05.23.
//

import Foundation

extension ICPStateCertificate {
    func verifySignature(rootKey: Data) throws {
        let message = ICPDomainSeparator("ic-state-root").data + tree.hash()
        try ICPCryptography.verifyBlsSignature(message: message, publicKey: rootKey, signature: signature)
        
        // TODO: handle delegation using ICPCryptography.rawBlsPublicKey(fromDER:) to validate its key.
    }
}

// MARK: Hashing
extension ICPStateCertificate.HashTreeNode {
    func hash() -> Data {
        let dataToHash: Data
        switch self {
        case .empty:
            dataToHash = ICPDomainSeparator("ic-hashtree-empty").data
        case .fork(let left, let right):
            dataToHash = ICPDomainSeparator("ic-hashtree-fork").data + left.hash() + right.hash()
        case .labeled(let label, let child):
            dataToHash = ICPDomainSeparator("ic-hashtree-labeled").data + label + child.hash()
        case .leaf(let data):
            dataToHash = ICPDomainSeparator("ic-hashtree-leaf").data + data
        case .pruned(let hash):
            // already hashed, just return it
            return hash
        }
        return ICPCryptography.sha256(dataToHash)
    }
}
