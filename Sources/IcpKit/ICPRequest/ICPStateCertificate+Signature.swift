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
        
        // TODO: handle delegation
        // TODO: verify object identifiers for public key in case of delegation
        //let asn1 = try ASN1Serialization.asn1(fromDER: <delegation_key>)
        // verify object identifiers :
        //  .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 1, 2, 1]),
        //  .objectIdentifier([1, 3, 6, 1, 4, 1, 44668, 5, 3, 2, 1])
        //let raw = asn1[0].collectionValue![1].bitStringValue!.bytes
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
