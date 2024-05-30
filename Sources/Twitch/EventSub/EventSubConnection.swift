import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class EventSubConnection {
  private let eventSubURL: URL

  private let credentials: TwitchCredentials
  private let urlSession: URLSession
  private let decoder: JSONDecoder

  private var keepaliveTimer: KeepaliveTimer?
  private var websocket: URLSessionWebSocketTask?
  private var socketID: String?

  private var onMessage: ((Result<EventSubNotification, EventSubConnectionError>) -> Void)
  private var welcomeContinuation: CheckedContinuation<EventSubWelcome, any Error>?

  // TODO: look into deinitilizations
  deinit {
    self.websocket?.cancel(with: .goingAway, reason: nil)
  }

  init(
    credentials: TwitchCredentials, urlSession: URLSession, decoder: JSONDecoder,
    eventSubURL: URL,
    onMessage: @escaping (Result<EventSubNotification, EventSubConnectionError>) -> Void
  ) {
    self.credentials = credentials
    self.urlSession = urlSession
    self.decoder = decoder

    self.eventSubURL = eventSubURL

    self.onMessage = onMessage
  }

  internal func resume() async throws -> String {
    if let socketID = self.socketID { return socketID }

    self.websocket = urlSession.webSocketTask(with: eventSubURL)
    self.websocket?.receive(completionHandler: receiveMessage(_:))
    self.websocket?.resume()

    // Twitch sends keepalive messages in a specified time interval,
    // if we don't receive a message within that interval, we should
    // consider the connection to be timed out
    self.keepaliveTimer = KeepaliveTimer(duration: .seconds(10)) {
      self.onMessage(
        .failure(EventSubConnectionError.timedOut(socketID: self.socketID ?? "")))
      self.websocket?.cancel()
    }

    // wait for the welcome message to be received
    let welcomeMessage = try await withCheckedThrowingContinuation { continuation in
      self.welcomeContinuation = continuation
    }

    // use a slightly longer keepalive timeout to account for network latency
    let timeout = welcomeMessage.keepaliveTimeout + .seconds(1)
    await self.keepaliveTimer?.reset(duration: timeout)

    self.socketID = welcomeMessage.sessionID
    return welcomeMessage.sessionID
  }

  private func receiveMessage(
    _ result: Result<URLSessionWebSocketTask.Message, any Error>
  ) {
    switch result {
    case .success(let message):
      // reset the keepalive timer on every message
      Task { await self.keepaliveTimer?.reset() }

      if let message = parseMessage(message) { handleMessage(message) }

      // recursively receive the next message
      self.websocket?.receive(completionHandler: receiveMessage)
    case .failure(let error):
      let disconnectedError = EventSubConnectionError.disconnected(
        with: error, socketID: socketID ?? "")

      if let welcomeContinuation {
        welcomeContinuation.resume(throwing: disconnectedError)
        self.welcomeContinuation = nil
      }

      onMessage(.failure(disconnectedError))
    }
  }

  private func parseMessage(_ message: URLSessionWebSocketTask.Message)
    -> EventSubMessage?
  {
    switch message {
    case .string(let string):
      return try? decoder.decode(EventSubMessage.self, from: Data(string.utf8))
    // ignore binary messages, Twitch only sends JSON
    case .data: return nil
    @unknown default: return nil
    }
  }

  private func handleMessage(_ message: EventSubMessage) {
    switch message.payload {
    case .keepalive: break  // nothing to do for keepalive messages
    case .welcome(let welcome):
      welcomeContinuation?.resume(returning: welcome)
      welcomeContinuation = nil
    case .notification(let notification):
      onMessage(.success(notification))
    case .revocation(let revocation):
      onMessage(.failure(EventSubConnectionError.revocation(revocation)))
    case .reconnect(let reconnect):
      onMessage(
        .failure(
          EventSubConnectionError.reconnectRequested(
            reconnectURL: reconnect.reconnectURL, socketID: socketID ?? "")))
    }
  }
}
