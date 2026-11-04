import Foundation
import IcpKit

/// Shared HTTP double. Each test owns its instance; recording is protected for concurrent requests.
public final class MockHttpClient: @unchecked Sendable, HttpClient {
    private let lock = NSLock()
    private var recordedRequests: [HttpRequest] = []
    private let handler: @Sendable (HttpRequest) throws -> HttpResponse

    public var requests: [HttpRequest] {
        lock.withLock { recordedRequests }
    }

    public var lastRequest: HttpRequest? { requests.last }

    public init(response: HttpResponse) {
        let data = response.data
        let statusCode = response.statusCode
        handler = { _ in HttpResponse(data: data, statusCode: statusCode) }
    }

    public init(handler: @escaping @Sendable (HttpRequest) throws -> HttpResponse) {
        self.handler = handler
    }

    public func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        lock.withLock { recordedRequests.append(request) }
        return try handler(request)
    }
}
