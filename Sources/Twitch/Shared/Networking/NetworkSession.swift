import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

protocol NetworkSession: Sendable {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
  func webSocketTask(with url: URL) async -> WebSocketTask
}

struct URLSessionNetworkSession: NetworkSession, @unchecked Sendable {
  let session: URLSession

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    try await session.data(for: request)
  }

  func webSocketTask(with url: URL) async -> WebSocketTask {
    URLSessionWebSocketTaskAdapter(task: session.webSocketTask(with: url))
  }
}
