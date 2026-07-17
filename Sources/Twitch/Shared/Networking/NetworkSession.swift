import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

protocol NetworkSession: Sendable {
  func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
  func webSocketTask(with url: URL) async -> WebSocketTask
}

struct URLSessionNetworkSession: NetworkSession, @unchecked Sendable {
  let session: URLSession

  func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    return (data, httpResponse)
  }

  func webSocketTask(with url: URL) async -> WebSocketTask {
    URLSessionWebSocketTaskAdapter(task: session.webSocketTask(with: url))
  }
}
