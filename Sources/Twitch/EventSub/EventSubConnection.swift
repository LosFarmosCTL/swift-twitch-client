import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// TODO: handle twitch closing the connection
internal actor EventSubConnection {
  private let eventsubURL: URL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!

  private let credentials: TwitchCredentials
  private let urlSession: URLSession
  private let decoder = JSONDecoder()

  private var websocket: URLSessionWebSocketTask?
  private var handlers = [String: EventSubHandler]()

  private var welcomeContinuation: CheckedContinuation<EventSubWelcome, any Error>?

  init(credentials: TwitchCredentials, urlSession: URLSession) async throws {
    self.credentials = credentials
    self.urlSession = urlSession
  }

  deinit {
    self.websocket?.cancel(with: .goingAway, reason: nil)
  }

  internal func connect() async throws -> String {
    // guard self.websocket == nil else { throw WebSocketError.alreadyConnected }
    self.websocket = urlSession.webSocketTask(with: eventsubURL)

    let welcomeMessage = try await withCheckedThrowingContinuation { continuation in
      self.welcomeContinuation = continuation

      self.websocket?.receive(completionHandler: receiveMessage)
      self.websocket?.resume()
    }

    return welcomeMessage.sessionID
  }

  private func receiveMessage(
    _ result: Result<URLSessionWebSocketTask.Message, any Error>
  ) {
    switch result {
    case .failure(let error):
      welcomeContinuation?.resume(throwing: error)

      for handler in handlers.values {
        handler.finish(throwing: error)
      }
    case .success(let message):
      switch message {
      case .string(let string):
        do {
          let message = try parseMessage(string)

          handleMessage(message)
        } catch {
          // ignore malformed messages, except for the welcome message
          welcomeContinuation?.resume(throwing: error)
        }
      case .data: fallthrough
      @unknown default: break
      }
    }
  }

  private func parseMessage(_ message: String) throws -> EventSubMessage {
    let data = message.data(using: .utf8)!

    return try decoder.decode(EventSubMessage.self, from: data)
  }

  private func handleMessage(_ message: EventSubMessage) {
    switch message.payload {
    case .welcome(let welcome):
      welcomeContinuation?.resume(returning: welcome)
    case .notification(let notification):
      if let handler = handlers[notification.subscription.id] {
        handler.yield(notification.event)
      }
    case .revocation(let revocation):
      if let handler = handlers[revocation.subscriptionID] {
        handler.finish(throwing: EventSubError.revocation)
      }
    case .reconnect(let reconnect): break
    case .keepalive: break
    }
  }
}
