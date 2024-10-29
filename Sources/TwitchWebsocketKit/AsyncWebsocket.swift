import Foundation
import NIO
import NIOWebSocket
import Twitch
import WebSocketKit

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class AsyncWebsocket {
  private let url: URL
  private let eventLoopGroup: EventLoopGroup

  private var websocket: WebSocket? = nil
  private var stream: AsyncThrowingStream<String, Error>?
  private var iterator: AsyncThrowingStream<String, Error>.Iterator?
  private var continuation: AsyncThrowingStream<String, Error>.Continuation?

  init(url: URL, eventLoopGroup: EventLoopGroup) {
    self.url = url
    self.eventLoopGroup = eventLoopGroup
  }

  func resume() throws {
    guard websocket == nil else {
      throw WebSocketError.alreadyConnected
    }

    let (stream, continuation) = AsyncThrowingStream<String, Error>.makeStream()
    self.stream = stream
    self.iterator = stream.makeAsyncIterator()
    self.continuation = continuation

    _ = WebSocket.connect(to: url, on: eventLoopGroup) { [weak self] ws in
      guard let self else {
        _ = ws.close(code: .goingAway)
        return
      }
      self.websocket = ws

      _ = ws.onClose.map {
        self.continuation?.finish()
      }

      ws.onText { ws, text in
        self.continuation?.yield(text)
      }
    }
  }

  func receive() async throws -> String? {
    return try await iterator?.next()
  }

  func send(_ text: String) async throws {
    try await websocket?.send(text)
  }

  func cancel(with code: WebSocketErrorCode) {
    _ = websocket?.close(code: code)
  }
}
