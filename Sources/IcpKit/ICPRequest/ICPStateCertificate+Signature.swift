//
//  ICPStateCertificate+Signature.swift
//
//  Created by Konstantinos Gaitanis on 12.05.23.
//

import Foundation

extension ICPStateCertificate {
    static let icpRootRawPublicKey = Data([0x81, 0x4c, 0x0e, 0x6e, 0xc7, 0x1f, 0xab, 0x58, 0x3b, 0x08, 0xbd, 0x81, 0x37, 0x3c, 0x25, 0x5c, 0x3c, 0x37, 0x1b, 0x2e, 0x84, 0x86, 0x3c, 0x98, 0xa4, 0xf1, 0xe0, 0x8b, 0x74, 0x23, 0x5d, 0x14, 0xfb, 0x5d, 0x9c, 0x0c, 0xd5, 0x46, 0xd9, 0x68, 0x5f, 0x91, 0x3a, 0x0c, 0x0b, 0x2c, 0xc5, 0x34, 0x15, 0x83, 0xbf, 0x4b, 0x43, 0x92, 0xe4, 0x67, 0xdb, 0x96, 0xd6, 0x5b, 0x9b, 0xb4, 0xcb, 0x71, 0x71, 0x12, 0xf8, 0x47, 0x2e, 0x0d, 0x5a, 0x4d, 0x14, 0x50, 0x5f, 0xfd, 0x74, 0x84, 0xb0, 0x12, 0x91, 0x09, 0x1c, 0x5f, 0x87, 0xb9, 0x88, 0x83, 0x46, 0x3f, 0x98, 0x09, 0x1a, 0x0b, 0xaa, 0xae])
    
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
