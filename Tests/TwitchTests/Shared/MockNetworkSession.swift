import Foundation

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

actor MockNetworkSession: NetworkSession {
  struct Key: Hashable {
    let url: URL
    let method: String
  }

  private var webSocketTasks: [MockWebSocketTask] = []
  var queuedWebSocketMessages: [URLSessionWebSocketTask.Message] = []
  var queuedWebSocketErrors: [Error] = []

  private var stubs: [Key: (Data, HTTPURLResponse)] = [:]
  private var onRequest: (@Sendable (URLRequest) async -> Void)?

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    await onRequest?(request)

    guard let url = request.url else { throw URLError(.badURL) }
    let method = request.httpMethod ?? "GET"

    if let hit = stubs[Key(url: url, method: method)] { return hit }
    throw URLError(.unsupportedURL)
  }

  func webSocketTask(with url: URL) async -> WebSocketTask {
    let task = MockWebSocketTask(url: url)

    for message in queuedWebSocketMessages {
      await task.simulateIncoming(message)
    }
    for error in queuedWebSocketErrors {
      await task.simulateError(error)
    }

    queuedWebSocketMessages.removeAll()
    queuedWebSocketErrors.removeAll()

    webSocketTasks.append(task)
    return task
  }

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

  func simulateIncoming(
    _ message: URLSessionWebSocketTask.Message,
    queue: Bool = false
  ) async {
    if queue {
      queuedWebSocketMessages.append(message)
      return
    }

    if let task = lastTask() {
      await task.simulateIncoming(message)
    } else {
      queuedWebSocketMessages.append(message)
    }
  }

  func simulateError(_ error: Error, queue: Bool = false) async {
    if queue {
      queuedWebSocketErrors.append(error)
      return
    }

    if let task = lastTask() {
      await task.simulateError(error)
    } else {
      queuedWebSocketErrors.append(error)
    }
  }

  func task(at index: Int) -> MockWebSocketTask? {
    webSocketTasks.indices.contains(index) ? webSocketTasks[index] : nil
  }

  func lastTask() -> MockWebSocketTask? {
    webSocketTasks.last
  }

  func onRequest(_ handler: @escaping @Sendable (URLRequest) async -> Void) {
    onRequest = handler
  }

  func reset() {
    stubs.removeAll()
    onRequest = nil
  }
}
