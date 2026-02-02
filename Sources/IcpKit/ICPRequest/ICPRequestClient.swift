//
//  ICPRequestClient.swift
//
//  Created by Konstantinos Gaitanis on 21.04.23.
//

import Foundation
import Candid

public enum ICPRequestRejectCode: UInt8, Decodable, Sendable {
    case systemFatal = 1
    case systemTransient = 2
    case destinationInvalid = 3
    case canisterReject = 4
    case canisterError = 5
}

public enum ICPRequestStatusCode: String, Decodable {
    case received
    case processing
    case replied
    case rejected
    case done
}

public enum ICPPollingError: Error {
    case malformedRequestId
    case requestIsDone
    case requestRejected(ICPRequestRejectCode, String?)
    case parsingError
    case timeout
}

public enum ICPRemoteClientError: Error {
    case httpError(Error, String?)
    case failed(statusCode: Int, error: String?)
    case invalidCborEncoding
    case requestRejected(rejectCode: ICPRequestRejectCode?, rejectMessage: String?, error_code: String?)
    case malformedResponse
    case noResponseData
    case missingRootKey
}

public struct ICPReadStateResponse {
    public let stateValues: [ICPStateTreePath: Data]
       
    public func stringValueForPath(endingWith suffix: String) -> String? {
        guard let data = rawValueForPath(endingWith: suffix) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func rawValueForPath(endingWith suffix: String) -> Data? {
        stateValues.first { (path, value) in
            path.components.last?.stringValue == suffix
        }?.value
    }
}

public enum ICPRequestCertification {
    case uncertified
    case certified
}

/// The HttpClient that takes care of encoding and serialising all requests
public final class ICPRequestClient: Sendable {
    private let client: any HttpClient
    public let network: ICPNetwork
    
    public init() {
        client = UrlSessionHttpClient()
        network = .mainnet
    }
    
    public init(_ client: any HttpClient) {
        self.client = client
        network = .mainnet
    }
    
    public init(network: ICPNetwork) {
        self.client = UrlSessionHttpClient()
        self.network = network
    }
    
    public init(network: ICPNetwork, client: any HttpClient) {
        self.client = client
        self.network = network
    }
    
    public func withRootKey(_ rootKey: Data) -> ICPRequestClient {
        ICPRequestClient(network: network.withRootKey(rootKey), client: client)
    }
    
    /// Makes a Query/Call Request to the given canister and returns the result.
    /// Queries do not affect the state of the blockchain and are generally fast.
    ///
    /// When the certification is `.uncertified`, this will perform a very fast query request which
    /// is not signed by ICP (therefore can be forged). Queries performed this way will result in a single HTTP request whose response contains the queried data.
    ///
    /// When the certification is `.certified`, this will perform a `callAndPoll`. Queries performed
    /// this way will result in multiple HTTP requests until a response is provided by the ICP.
    ///
    /// - Parameters:
    ///   - certification: the certification level
    ///   - method: the method
    ///   - canister: the canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    /// - Returns: the response
    public func query(_ certification: ICPRequestCertification, _ method: ICPMethod, effectiveCanister canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> [CandidValue] {
        switch certification {
        case .uncertified: return try await query(method, effectiveCanister: canister, sender: sender)
        case .certified: return try await callAndPoll(method, effectiveCanister: canister, sender: sender)
        }
    }
    
    /// Makes a Call Request to ICP.
    /// Calls can potentially affect the blockchain state and are always signed by the ICP.
    ///
    /// The response is just the requestId. Upon receiving a response from this call, it does not mean that the ICP has processed the request. The status of the request can be queried using
    /// `pollRequestStatus`.
    ///
    /// - Parameters:
    ///   - method: The method to be called
    ///   - canister: The canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    /// - Returns: the requestId of the newly created request
    public func call(_ method: ICPMethod, effectiveCanister canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Data {
        let icpRequest = try await ICPRequest(.call(method), canister: canister, sender: sender, network: network)
        _ = try await fetchCbor(icpRequest, canister: canister)
        return icpRequest.requestId
    }
    
    /// Makes a call request and then polls the canister until the request has been either processed or has failed.
    /// - Parameters:
    ///   - method: The method to be called
    ///   - canister: The canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    ///   - duration: The maximum duration of polling
    ///   - waitDuration: The wait time between two consecutive polls
    /// - Returns: The response of the request
    // TODO: return [CandidValue]
    public func callAndPoll(_ method: ICPMethod,
                     effectiveCanister canister: ICPPrincipal,
                     sender: ICPSigningPrincipal? = nil,
                     for duration: Duration = .seconds(120),
                     repeatEvery waitDuration: Duration = .seconds(2)) async throws -> [CandidValue] {
        let requestId = try await call(method, effectiveCanister: canister, sender: sender)
        return try await pollRequestStatus(requestId: requestId,
                                           effectiveCanister: canister,
                                           sender: sender,
                                           for: duration,
                                           repeatEvery: waitDuration)
    }
    
    /// Performs a Query request to the canister and returns the response
    /// - Parameters:
    ///   - method: The method to be called
    ///   - canister: The canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    /// - Returns: The response of the query
    // TODO: return [CandidValue]
    public func query(_ method: ICPMethod, effectiveCanister canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> [CandidValue] {
        let icpRequest = try await ICPRequest(.query(method), canister: canister, sender: sender, network: network)
        guard let cborEncodedResponse = try await fetchCbor(icpRequest, canister: canister) else {
            throw ICPRemoteClientError.noResponseData
        }
        let parsedResponse = try parseQueryResponse(cborEncodedResponse)
        return parsedResponse
    }
    
    /// Performs a ReadState request to the canister.
    /// - Parameters:
    ///   - paths: The Paths of the State Tree we wish to query
    ///   - canister: The canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    /// - Returns: The ReadState response
    public func readState(paths: [ICPStateTreePath], effectiveCanister canister: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ICPReadStateResponse {
        let icpRequest = try await ICPRequest(.readState(paths: paths), canister: canister, sender: sender, network: network)
        guard let cborEncodedResponse = try await fetchCbor(icpRequest, canister: canister) else {
            throw ICPRemoteClientError.noResponseData
        }
        let parsedResponse = try parseReadStateResponse(cborEncodedResponse, paths, rootKey: network.rootKey, verifySignature: network.verifyCertificates)
        return parsedResponse
    }
    
    /// Fetches and returns the root key from the network's status endpoint.
    /// This is required for certificate validation when using a local replica.
    public func fetchRootKey() async throws -> Data {
        let request = HttpRequest(
            method: "GET",
            url: network.statusURL,
            body: nil,
            headers: [:],
            timeout: 30)
        let response = try await client.fetch(request)
        guard response.statusCode == 200 else {
            let errorString = String(data: response.data ?? Data(), encoding: .utf8)
            throw ICPRemoteClientError.failed(statusCode: response.statusCode, error: errorString)
        }
        guard let data = response.data else {
            throw ICPRemoteClientError.noResponseData
        }
        let status = try ICPCryptography.CBOR.deserialise(StatusResponseDecodable.self, from: data)
        guard let rootKey = status.root_key else {
            throw ICPRemoteClientError.missingRootKey
        }
        return rootKey
    }
    
    /// Will poll the canister every `waitDuration` for the response of the request with the given requestId until we
    /// either get a response or the `duration` is exceeded
    /// - Parameters:
    ///   - requestId: the requestId that we are querying
    ///   - canister: the canister
    ///   - sender: The signer of the request. If not present, no signature will be attached to the request.
    ///   - duration: The duration for the polling will take place, defaults to 2 minutes
    ///   - waitDuration: The time between two consecutive calls, defaults to 2 seconds
    /// - Returns: The response of the query
    // TODO: return [CandidValue]
    public func pollRequestStatus(requestId: Data,
                           effectiveCanister canister: ICPPrincipal,
                           sender: ICPSigningPrincipal? = nil,
                           for duration: Duration = .seconds(120),
                           repeatEvery waitDuration: Duration = .seconds(2)) async throws -> [CandidValue] {
            let endTime = Date.now.addingTimeInterval(TimeInterval(duration.components.seconds))
            let paths: [ICPStateTreePath] = [
                ["time"],
                ["request_status", .data(requestId), "status"],
                ["request_status", .data(requestId), "reply"],
                ["request_status", .data(requestId), "reject_code"],
                ["request_status", .data(requestId), "reject_message"]
            ].map { ICPStateTreePath($0) }
            
            repeat {
                let statusResponse = try await readState(paths: paths, effectiveCanister: canister, sender: sender)
                if let statusString = statusResponse.stringValueForPath(endingWith: "status") {
                    guard let status = ICPRequestStatusCode(rawValue: statusString) else {
                        throw ICPPollingError.parsingError
                    }
                    switch status {
                    case .done:
                        throw ICPPollingError.requestIsDone
                        
                    case .rejected:
                        guard let rejectCodeValue = statusResponse.rawValueForPath(endingWith: "reject_code"),
                              let rejectCode = ICPRequestRejectCode(rawValue: UInt8.from(rejectCodeValue)) else {
                            throw ICPPollingError.parsingError
                        }
                        let rejectMessage = statusResponse.stringValueForPath(endingWith: "reject_message")
                        throw ICPPollingError.requestRejected(rejectCode, rejectMessage)
                        
                    case .replied:
                        guard let replyData = statusResponse.rawValueForPath(endingWith: "reply") else {
                            throw ICPPollingError.parsingError
                        }
                        let candidValue = try CandidDeserialiser().decode(replyData)
                        return candidValue
                        
                    case .processing:
                        // wait and try again later
                        break
                        
                    case .received:
                        // wait and try again later
                        break
                    }
                }
                try await Task.sleep(for: waitDuration)
            } while endTime > .now
            
            throw ICPPollingError.timeout
    }
    
    private func fetchCbor(_ icpRequest: ICPRequest, canister: ICPPrincipal, sender: ICPPrincipal? = nil) async throws -> Data? {
        let response = try await client.fetch(icpRequest.httpRequest)
        
        guard response.statusCode == 200 || response.statusCode == 202 else {
            let errorString = String(data: response.data ?? Data(), encoding: .utf8)
            throw ICPRemoteClientError.failed(statusCode: response.statusCode, error: errorString)
        }
        return response.data
    }
    
    // TODO: return [CandidValue]
    private func parseQueryResponse(_ data: Data) throws -> [CandidValue] {
        let queryResponse = try ICPCryptography.CBOR.deserialise(QueryResponseDecodable.self, from: data)
        guard queryResponse.status != .rejected else {
            throw ICPRemoteClientError.requestRejected(
                rejectCode: queryResponse.reject_code,
                rejectMessage: queryResponse.reject_message,
                error_code: queryResponse.error_code)
        }
        guard let candidRaw = queryResponse.reply?.arg else {
            throw ICPRemoteClientError.malformedResponse
        }
        let candidResponse = try CandidDeserialiser().decode(candidRaw)
        return candidResponse
    }
    
    private func parseCallResponse(_ data: Data) throws -> CandidValue {
        return .null
    }
    
    private func parseReadStateResponse(_ data: Data, _ paths: [ICPStateTreePath], rootKey: Data?, verifySignature: Bool) throws -> ICPReadStateResponse {
        let readStateResponse = try ICPCryptography.CBOR.deserialise(ReadStateResponseDecodable.self, from: data)
        let certificateCbor = try ICPCryptography.CBOR.deserialiseCbor(from: readStateResponse.certificate)
        let certificate = try ICPStateCertificate.parse(certificateCbor)
        if verifySignature {
            guard let rootKey else { throw ICPRemoteClientError.missingRootKey }
            try certificate.verifySignature(rootKey: rootKey)
        }
        let pathResponses = Dictionary(uniqueKeysWithValues: paths
            .map { ($0, certificate.tree.getValue(for: $0)) }
            .filter { $0.1 != nil }
            .map { ($0.0, $0.1!) }
        )
        
        return ICPReadStateResponse(stateValues: pathResponses)
    }
}


private struct QueryResponseDecodable: Decodable {
    let status: ICPRequestStatusCode
    let reply: Reply?
    let reject_code: ICPRequestRejectCode?
    let reject_message: String?
    let error_code: String?
    
    struct Reply: Decodable {
        let arg: Data
    }
}

private struct ReadStateResponseDecodable: Decodable {
    let certificate: Data
}

private struct StatusResponseDecodable: Decodable {
    let root_key: Data?
}
