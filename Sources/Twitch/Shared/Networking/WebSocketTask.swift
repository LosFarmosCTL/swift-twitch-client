import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

protocol WebSocketTask: Sendable {
  func resume() async
  func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) async

  func send(_ message: URLSessionWebSocketTask.Message, ) async throws

  func receive(
    completionHandler:
      @Sendable @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void
  ) async

  func receive() async throws -> URLSessionWebSocketTask.Message
}

final class URLSessionWebSocketTaskAdapter: WebSocketTask {
  private let task: URLSessionWebSocketTask
  init(task: URLSessionWebSocketTask) { self.task = task }

  func resume() { task.resume() }

  func cancel(
    with closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) { task.cancel(with: closeCode, reason: reason) }

  func send(_ message: URLSessionWebSocketTask.Message) async throws {
    try await task.send(message)
  }

  func receive(
    completionHandler:
      @Sendable @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void
  ) { task.receive(completionHandler: completionHandler) }

  func receive() async throws -> URLSessionWebSocketTask.Message {
    return try await task.receive()
  }
}
