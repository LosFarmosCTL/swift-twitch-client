import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension WebsocketTaskCloseCode {
  var urlSessionWebsocketCloseCode: URLSessionWebSocketTask.CloseCode {
    switch self {
    case .goingAway: .goingAway
    case .serverError: .internalServerError
    }
  }
}

extension URLSessionWebSocketTask: WebsocketTask {
  public func receive() async throws -> String? {
    guard case let .string(text) = try await self.receive() else {
      return nil
    }

    return text
  }

  public func send(_ text: String) async throws {
    try await self.send(.string(text))
  }

  public func cancel(with code: WebsocketTaskCloseCode) {
    self.cancel(with: code.urlSessionWebsocketCloseCode, reason: nil)
  }
}

extension URLSession: WebsocketTaskProvider {
  public typealias Task = URLSessionWebSocketTask

  public func task(with url: URL) -> Task {
    self.webSocketTask(with: url)
  }
}
