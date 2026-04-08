import Foundation

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

actor MockWebSocketTask: WebSocketTask {
  private(set) var didResume = false
  private(set) var didCancel = false
  private(set) var sentMessages: [URLSessionWebSocketTask.Message] = []
  private var pendingReceives:
    [@Sendable (Result<URLSessionWebSocketTask.Message, Error>) -> Void] = []
  private var pendingMessages: [URLSessionWebSocketTask.Message] = []
  private var pendingErrors: [Error] = []

  let url: URL

  init(url: URL) {
    self.url = url
  }

  func resume() { didResume = true }

  func cancel(
    with closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    didCancel = true
    pendingErrors.append(URLError(.cancelled))

    let pendingReceives = self.pendingReceives
    self.pendingReceives.removeAll()

    for handler in pendingReceives {
      handler(.failure(URLError(.cancelled)))
    }
  }

  func send(
    _ message: URLSessionWebSocketTask.Message
  ) throws {
    guard !didCancel else { throw URLError(.cancelled) }
    sentMessages.append(message)
  }

  func receive(
    completionHandler:
      @escaping @Sendable (Result<URLSessionWebSocketTask.Message, Error>) -> Void
  ) {
    guard pendingErrors.isEmpty else {
      let error = pendingErrors.removeFirst()
      completionHandler(.failure(error))
      return
    }

    guard pendingMessages.isEmpty else {
      let message = pendingMessages.removeFirst()
      completionHandler(.success(message))
      return
    }

    pendingReceives.append(completionHandler)
  }

  func receive() async throws -> URLSessionWebSocketTask.Message {
    return try await withCheckedThrowingContinuation { continuation in
      receive {
        continuation.resume(with: $0)
      }
    }
  }

  func simulateIncoming(_ message: URLSessionWebSocketTask.Message) {
    guard !pendingReceives.isEmpty else {
      pendingMessages.append(message)
      return
    }

    let handler = pendingReceives.removeFirst()
    handler(.success(message))
  }

  func simulateError(_ error: Error) {
    guard !pendingReceives.isEmpty else {
      pendingErrors.append(error)
      return
    }

    let handler = pendingReceives.removeFirst()
    handler(.failure(error))
  }
}
