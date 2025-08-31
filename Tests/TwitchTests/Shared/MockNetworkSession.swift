import Foundation

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

actor MockNetworkSession: NetworkSession {
  private let webSocketTask: WebSocketTask

  struct Key: Hashable {
    let url: URL
    let method: String
  }

  private var stubs: [Key: (Data, HTTPURLResponse)] = [:]
  private var onRequest: (@Sendable (URLRequest) -> Void)?

  init(webSocketTask: WebSocketTask) {
    self.webSocketTask = webSocketTask
  }

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    onRequest?(request)

    guard let url = request.url else { throw URLError(.badURL) }
    let method = request.httpMethod ?? "GET"

    if let hit = stubs[Key(url: url, method: method)] { return hit }
    throw URLError(.unsupportedURL)
  }

  func webSocketTask(with url: URL) async -> WebSocketTask { webSocketTask }

  func stub(
    url: URL, method: String = "GET",
    status: Int = 200,
    headers: [String: String] = [:],
    body: Data = Data()
  ) {
    let response = HTTPURLResponse(
      url: url,
      statusCode: status,
      httpVersion: "HTTP/1.1",
      headerFields: headers)!

    stubs[Key(url: url, method: method)] = (body, response)
  }

  func onRequest(_ handler: @escaping @Sendable (URLRequest) -> Void) {
    onRequest = handler
  }

  func reset() {
    stubs.removeAll()
    onRequest = nil
  }
}
