import Foundation

public enum WebsocketTaskCloseCode {
  case goingAway
  case serverError
}

public protocol WebsocketTask {
  func resume() throws
  func receive() async throws -> String?
  func send(_ text: String) async throws
  func cancel(with code: WebsocketTaskCloseCode)
}

public protocol WebsocketTaskProvider<Task> {
  associatedtype Task: WebsocketTask
  func task(with: URL) -> Task
}
