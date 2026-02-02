//
//  ICPNetwork.swift
//

import Foundation

public struct ICPNetwork: Sendable {
    public let baseURL: URL
    public let canisterBaseURL: URL
    public let statusURL: URL
    public let verifyCertificates: Bool
    public let rootKey: Data?

    public static let mainnet = ICPNetwork(
        baseURL: URL(string: "https://icp-api.io")!,
        rootKey: ICPStateCertificate.icpRootRawPublicKey,
        verifyCertificates: true
    )

    public init(
        baseURL: URL, rootKey: Data? = nil,
        verifyCertificates: Bool = true
    ) {
        self.baseURL = baseURL
        self.rootKey = rootKey ?? ICPStateCertificate.icpRootRawPublicKey
        self.verifyCertificates = verifyCertificates
        self.canisterBaseURL = ICPNetwork.buildCanisterBaseURL(baseURL)
        self.statusURL = ICPNetwork.buildStatusURL(baseURL)
    }

    public func withRootKey(_ rootKey: Data?) -> ICPNetwork {
        ICPNetwork(baseURL: baseURL, rootKey: rootKey, verifyCertificates: verifyCertificates)
    }

    public static func local(baseURL: URL, verifyCertificates: Bool = false) -> ICPNetwork {
        ICPNetwork(baseURL: baseURL, rootKey: nil, verifyCertificates: verifyCertificates)
    }

    private static func buildCanisterBaseURL(_ baseURL: URL) -> URL {
        var url = baseURL
        url.append(path: "api")
        url.append(path: "v2")
        url.append(path: "canister")
        return url
    }

    private static func buildStatusURL(_ baseURL: URL) -> URL {
        var url = baseURL
        url.append(path: "api")
        url.append(path: "v2")
        url.append(path: "status")
        return url
    }
}
