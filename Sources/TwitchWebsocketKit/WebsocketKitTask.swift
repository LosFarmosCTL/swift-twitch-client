import Foundation
import NIO
import NIOWebSocket
import Twitch
import WebSocketKit

public final class WebsocketKitTask: WebsocketTask {
  private static let connectionTimeout: TimeInterval = 30
  private static let connectionCheckSleep: TimeInterval = 0.1

  private let url: URL
  private let eventLoopGroup: EventLoopGroup

  private var websocket: WebSocket? = nil
  private var stream: AsyncThrowingStream<String, Error>?
  private var iterator: AsyncThrowingStream<String, Error>.Iterator?
  private var continuation: AsyncThrowingStream<String, Error>.Continuation?

  private var connected: Bool = false

  init(url: URL, eventLoopGroup: EventLoopGroup) {
    self.url = url
    self.eventLoopGroup = eventLoopGroup
  }

  public func resume() throws {
    guard websocket == nil else {
      throw WebSocketError.alreadyConnected
    }

    let (stream, continuation) = AsyncThrowingStream<String, Error>.makeStream()
    self.stream = stream
    self.iterator = stream.makeAsyncIterator()
    self.continuation = continuation

    try WebSocket.connect(to: url, on: eventLoopGroup) { [weak self] ws in
      guard let self else {
        _ = ws.close(code: .goingAway)
        return
      }
      self.websocket = ws

      _ = ws.onClose.map {
        self.continuation?.finish()
      }

      ws.onPing { ws, buffer in
        self.continuation?.yield("PING :")
      }

      ws.onPong { ws, buffer in
        // Skip first pong coming from our connection ping
        guard self.connected else {
          self.connected = true
          return
        }
        self.continuation?.yield("PONG :")
      }

      ws.onText { ws, text in
        self.continuation?.yield(text)
      }

      // Kickoff the connectiong with a ping
      ws.sendPing()
    }.wait()
  }

  public func receive() async throws -> String? {
    try await ensureConnection()
    return try await iterator?.next()
  }

  public func send(_ text: String) async throws {
    try await ensureConnection()
    try await websocket?.send(text)
  }

  public func cancel(with code: WebsocketTaskCloseCode) {
    _ = websocket?.close(code: code.websoketKitCloseCode)
  }

  private func ensureConnection() async throws {
    if websocket != nil, connected {
      return
    }

    let start = Date.now
    while websocket == nil, !connected {
      try await Task.sleep(for: .seconds(Self.connectionCheckSleep))

      let time = Date.now.timeIntervalSince(start)
      if time > Self.connectionTimeout {
        throw WebSocketError.connectionTimeout
      }
    }
  }
}

extension Twitch.WebsocketTaskCloseCode {
  var websoketKitCloseCode: WebSocketErrorCode {
    switch self {
    case .goingAway: .goingAway
    case .serverError: .unexpectedServerError
    }
  }
}
