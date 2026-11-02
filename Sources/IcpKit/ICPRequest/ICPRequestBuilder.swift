//
//  ICPRequestBuilder.swift
//
//  Created by Konstantinos Gaitanis on 02.05.23.
//

import Foundation
import Candid

public enum ICPRequestBuilder {
    public static let defaultIngressExpirySeconds: TimeInterval = 4 * 60 // 4 minutes
    
    public static func buildContent(_ request: ICPRequestType, sender: ICPPrincipal?) throws -> ICPRequestContent {
        let nonce = try ICPCryptography.secureRandom(32)
        let ingressExpiry = createIngressExpiry()
        let senderBytes = sender?.bytes ?? Data([4])
        
        switch request {
        case .readState(let paths):
            let encodedPaths = paths.map { $0.encodedComponents() }
            return ReadStateRequestContent(
                request_type: .readState,
                sender: senderBytes,
                nonce: nonce,
                ingress_expiry: ingressExpiry,
                paths: encodedPaths
            )
            
        case .call(let method), .query(let method):
            let serialisedArgs = CandidSerialiser().encode(method.args)
            return CallRequestContent(
                request_type: .from(request),
                sender: senderBytes,
                nonce: nonce,
                ingress_expiry: ingressExpiry,
                method_name: method.methodName,
                canister_id: method.canister.bytes,
                arg: serialisedArgs
            )
        }
    }
    
    public static func buildEnvelope(_ content: ICPRequestContent, sender: ICPSigningPrincipal?, canister: ICPPrincipal? = nil) async throws -> ICPRequestEnvelope {
        guard let sender = sender else {
            return ICPRequestEnvelope(content: content)
        }
        let senderDelegation = sender.delegationChain
        guard senderDelegation.count <= 20 else { throw ICPDelegatedIdentity.Error.chainTooLong }
        try ICPDelegatedIdentity.validateExpiration(senderDelegation, now: ICPDelegatedIdentity.currentTime())
        // Call/query restrictions apply to the content's destination; read_state needs its URL canister.
        let destination = (content as? CallRequestContent).map { ICPPrincipal($0.canister_id) } ?? canister
        try ICPDelegatedIdentity.validateTargets(senderDelegation, canister: destination)
        let senderPublicKey = try sender.publicKey.derRepresentation
        let requestId = try content.calculateRequestId()
        let senderSignature = try await sender.sign(requestId, domain: "ic-request")
        try ICPDelegatedIdentity.validateExpiration(senderDelegation, now: ICPDelegatedIdentity.currentTime())
        return ICPRequestEnvelope(
            content: content,
            sender_pubkey: senderPublicKey,
            sender_sig: senderSignature,
            sender_delegation: senderDelegation
        )        
    }
    
    private static func createIngressExpiry(_ seconds: TimeInterval = defaultIngressExpirySeconds) -> Int {
        let expiryDate = Date.now.addingTimeInterval(defaultIngressExpirySeconds)
        let nanoSecondsSince1970 = expiryDate.timeIntervalSince1970 * 1_000_000_000
        return Int(nanoSecondsSince1970)
    }
}
