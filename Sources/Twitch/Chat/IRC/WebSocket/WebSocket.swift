import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class WebSocket {
  private let websocket: URLSessionWebSocketTask

  init(from url: URL) {
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    self.websocket = session.webSocketTask(with: url)
  }

  internal func connect() throws -> AsyncThrowingStream<String, Error> {
    if self.websocket.state == .running {
      throw WebSocketError.alreadyConnected
    }

    self.websocket.resume()

    return AsyncThrowingStream(unfolding: {
      let message = try? await self.websocket.receive()
      guard let message = message else { throw WebSocketError.disconnected }

      switch message {
      case .string(let text): return text
      case .data(let data):
        self.disconnect(with: .unsupportedData)
        throw WebSocketError.invalidMessageReceived(data: data)
      }
    })
  }

  internal func disconnect(with statusCode: URLSessionWebSocketTask.CloseCode) {
    self.websocket.cancel(with: statusCode, reason: nil)
  }

  internal func send(_ message: String) async throws {
    try await self.websocket.send(.string(message))
  }
}
