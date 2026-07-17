import Foundation

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

actor MockNetworkSession: NetworkSession {
  struct Key: Hashable {
    struct QueryItem: Hashable {
      let name: String
      let value: String?
    }

    let scheme: String?
    let host: String?
    let port: Int?
    let path: String
    let queryItems: [QueryItem]
    let method: String

    init(url: URL, method: String) {
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

      self.scheme = components?.scheme?.lowercased()
      self.host = components?.host?.lowercased()
      self.port = components?.port
      self.path = components?.percentEncodedPath ?? url.path
      self.queryItems = (components?.queryItems ?? [])
        .map { QueryItem(name: $0.name, value: $0.value) }
        .sorted {
          if $0.name == $1.name {
            return ($0.value ?? "") < ($1.value ?? "")
          }
          return $0.name < $1.name
        }
      self.method = method
    }
  }

  private enum Stub {
    case response(Data, HTTPURLResponse)
    case failure(any Error)
  }

  private var webSocketTasks: [MockWebSocketTask] = []
  private var taskWaiters: [Int: [CheckedContinuation<MockWebSocketTask, Never>]] = [:]
  var queuedWebSocketMessages: [URLSessionWebSocketTask.Message] = []
  var queuedWebSocketErrors: [Error] = []

  private var stubs: [Key: Stub] = [:]
  private var onRequest: (@Sendable (URLRequest) async -> Void)?
  private var receivedRequests: [URLRequest] = []

  func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    guard let url = request.url else { throw URLError(.badURL) }
    let method = request.httpMethod ?? "GET"
    let key = Key(url: url, method: method)

    guard let stub = stubs[key] else { throw URLError(.unsupportedURL) }

    receivedRequests.append(request)
    let requestHandler = onRequest
    await requestHandler?(request)

    switch stub {
    case .response(let data, let response):
      return (data, response)
    case .failure(let error):
      throw error
    }
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

    let index = webSocketTasks.count - 1
    if let waiters = taskWaiters.removeValue(forKey: index) {
      for waiter in waiters {
        waiter.resume(returning: task)
      }
    }

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

    stubs[Key(url: url, method: method)] = .response(body, response)
  }

  func stub(url: URL, method: String = "GET", error: any Error) {
    stubs[Key(url: url, method: method)] = .failure(error)
  }

  func requests() -> [URLRequest] {
    receivedRequests
  }

  func lastRequest() -> URLRequest? {
    receivedRequests.last
  }

  func requestCount() -> Int {
    receivedRequests.count
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

  func waitForTask(at index: Int) async -> MockWebSocketTask {
    if let task = task(at: index) {
      return task
    }

    return await withCheckedContinuation { continuation in
      taskWaiters[index, default: []].append(continuation)
    }
  }

  func taskCount() -> Int {
    webSocketTasks.count
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
    receivedRequests.removeAll()
  }
}
