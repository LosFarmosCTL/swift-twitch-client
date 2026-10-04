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
  private var sendWaiters: [(String, Int, CheckedContinuation<Void, Never>)] = []

  private var cancellationWaiters: [CheckedContinuation<Void, Never>] = []
  private var sendHandler: (@Sendable () async throws -> Void)?
  private var cancellationHandler: (@Sendable () async -> Void)?

  let url: URL

  init(url: URL) {
    self.url = url
  }

  func resume() {
    didResume = true
  }

  func cancel(
    with closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) async {
    didCancel = true

    for waiter in cancellationWaiters {
      waiter.resume()
    }

    cancellationWaiters.removeAll()
    pendingErrors.append(URLError(.cancelled))

    let pendingReceives = self.pendingReceives
    self.pendingReceives.removeAll()

    for handler in pendingReceives {
      handler(.failure(URLError(.cancelled)))
    }

    await cancellationHandler?()
  }

  func waitForCancellation() async {
    guard !didCancel else {
      return
    }

    await withCheckedContinuation {
      cancellationWaiters.append($0)
    }
  }

  func send(
    _ message: URLSessionWebSocketTask.Message
  ) async throws {
    guard !didCancel else {
      throw URLError(.cancelled)
    }

    if let sendHandler {
      try await sendHandler()

      guard !didCancel else { throw URLError(.cancelled) }
    }

    sentMessages.append(message)

    let satisfied = sendWaiters.filter { sentCount(prefix: $0.0) >= $0.1 }
    sendWaiters.removeAll { sentCount(prefix: $0.0) >= $0.1 }

    for waiter in satisfied {
      waiter.2.resume()
    }
  }

  func onSend(_ handler: @escaping @Sendable () async throws -> Void) {
    sendHandler = handler
  }

  func onCancellation(_ handler: @escaping @Sendable () async -> Void) {
    cancellationHandler = handler
  }

  func sentCount(prefix: String) -> Int {
    sentMessages.filter {
      if case .string(let text) = $0 {
        return text.hasPrefix(prefix)
      }

      return false
    }.count
  }

  func waitForSent(_ prefix: String, count: Int = 1) async {
    guard sentCount(prefix: prefix) < count else {
      return
    }

    await withCheckedContinuation {
      sendWaiters.append((prefix, count, $0))
    }
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
