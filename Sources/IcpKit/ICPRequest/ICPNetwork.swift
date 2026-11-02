//
//  ICPNetwork.swift
//

import Foundation

/// Network endpoints and the optional trust anchor used by an ICP request client.
///
/// A root key enables certificate signature verification. A nil key skips verification.
public struct ICPNetwork: Sendable {
    /// Base URL of the replica or gateway, before the `/api/v2` path.
    public let baseURL: URL
    /// Base URL for canister requests, formed by appending `/api/v2/canister`.
    public let canisterBaseURL: URL
    /// Status endpoint, formed by appending `/api/v2/status` to the base URL.
    public let statusURL: URL
    /// Raw BLS public key used to verify certificates. Nil disables verification.
    public let rootKey: Data?

    /// The public ICP network, configured with its pinned raw BLS root key.
    public static let mainnet = ICPNetwork(
        baseURL: URL(string: "https://icp-api.io")!,
        rootKey: mainnetRootKey
    )

    /// Creates a network configuration for a replica or gateway.
    ///
    /// - Parameters:
    ///   - baseURL: The server URL, without the `/api/v2` endpoint path.
    ///   - rootKey: The raw 96-byte BLS public key used to verify certificates.
    ///     Pass nil to skip verification. No mainnet key is substituted.
    public init(baseURL: URL, rootKey: Data? = nil) {
        self.baseURL = baseURL
        self.rootKey = rootKey
        self.canisterBaseURL = ICPNetwork.buildCanisterBaseURL(baseURL)
        self.statusURL = ICPNetwork.buildStatusURL(baseURL)
    }

    /// Returns a copy of this network with the supplied certificate verification key.
    ///
    /// - Parameter rootKey: A raw 96-byte BLS public key, such as the value returned by
    ///   `ICPRequestClient.fetchRootKey()`. Pass nil to disable certificate verification.
    /// - Returns: A network with the same endpoints and the supplied key.
    public func withRootKey(_ rootKey: Data?) -> ICPNetwork {
        ICPNetwork(baseURL: baseURL, rootKey: rootKey)
    }

    /// Creates a local replica configuration with certificate verification disabled.
    ///
    /// Fetch the replica's root key and install it with `withRootKey(_:)` to enable verification.
    ///
    /// - Parameter baseURL: The local replica URL, such as `http://127.0.0.1:4943`.
    /// - Returns: A network with the supplied base URL and no root key.
    public static func local(baseURL: URL) -> ICPNetwork {
        ICPNetwork(baseURL: baseURL)
    }

    private static let mainnetRootKey = Data([0x81, 0x4c, 0x0e, 0x6e, 0xc7, 0x1f, 0xab, 0x58, 0x3b, 0x08, 0xbd, 0x81, 0x37, 0x3c, 0x25, 0x5c, 0x3c, 0x37, 0x1b, 0x2e, 0x84, 0x86, 0x3c, 0x98, 0xa4, 0xf1, 0xe0, 0x8b, 0x74, 0x23, 0x5d, 0x14, 0xfb, 0x5d, 0x9c, 0x0c, 0xd5, 0x46, 0xd9, 0x68, 0x5f, 0x91, 0x3a, 0x0c, 0x0b, 0x2c, 0xc5, 0x34, 0x15, 0x83, 0xbf, 0x4b, 0x43, 0x92, 0xe4, 0x67, 0xdb, 0x96, 0xd6, 0x5b, 0x9b, 0xb4, 0xcb, 0x71, 0x71, 0x12, 0xf8, 0x47, 0x2e, 0x0d, 0x5a, 0x4d, 0x14, 0x50, 0x5f, 0xfd, 0x74, 0x84, 0xb0, 0x12, 0x91, 0x09, 0x1c, 0x5f, 0x87, 0xb9, 0x88, 0x83, 0x46, 0x3f, 0x98, 0x09, 0x1a, 0x0b, 0xaa, 0xae])

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
