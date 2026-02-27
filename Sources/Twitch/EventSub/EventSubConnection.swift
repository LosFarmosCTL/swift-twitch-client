import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor EventSubConnection {
  private let eventSubURL: URL

  private let credentials: TwitchCredentials
  private let network: NetworkSession
  private let decoder: JSONDecoder

  private var keepaliveTimer: KeepaliveTimer?
  private var websocket: WebSocketTask?
  private var socketID: String?

  private var isClosing = false

  private var onMessage:
    (@Sendable (Result<EventSubNotification, EventSubConnectionError>) async -> Void)

  private var welcomeContinuation: CheckedContinuation<EventSubWelcome, any Error>?
  private var pendingWelcomeResult: Result<EventSubWelcome, EventSubConnectionError>?

  private var receivedMessageIDs = [String]()

  internal func cancel() async {
    isClosing = true

    finishWelcome(
      .failure(
        EventSubConnectionError.disconnected(
          with: CancellationError(),
          socketID: socketID ?? "")))

    await websocket?.cancel(with: .goingAway, reason: nil)
    await keepaliveTimer?.cancel()
  }

  init(
    credentials: TwitchCredentials,
    network: NetworkSession,
    decoder: JSONDecoder,
    eventSubURL: URL,
    onMessage:
      @Sendable @escaping (Result<EventSubNotification, EventSubConnectionError>) async ->
      Void
  ) {
    self.credentials = credentials
    self.network = network
    self.decoder = decoder

    self.eventSubURL = eventSubURL

    self.onMessage = onMessage
  }

  internal func resume() async throws -> String {
    isClosing = false

    if let socketID = self.socketID { return socketID }

    self.websocket = await network.webSocketTask(with: eventSubURL)
    await self.websocket?.resume()
    await self.scheduleReceive()

    // Twitch sends keepalive messages in a specified time interval,
    // if we don't receive a message within that interval, we should
    // consider the connection to be timed out
    self.keepaliveTimer = KeepaliveTimer(duration: .seconds(7)) {
      @Sendable [weak self] in

      await self?.handleKeepaliveTimeout()
    }

    // wait for the welcome message to be received
    let welcomeMessage = try await withCheckedThrowingContinuation { continuation in
      self.welcomeContinuation = continuation

      // in case the welcome message was received before the continuation was set
      if let pending = self.pendingWelcomeResult {
        self.pendingWelcomeResult = nil
        self.finishWelcome(pending)
      }
    }

    // use a slightly longer keepalive timeout to account for network latency
    let timeout = welcomeMessage.keepaliveTimeout + .seconds(1)
    await self.keepaliveTimer?.reset(duration: timeout)

    self.socketID = welcomeMessage.sessionID
    return welcomeMessage.sessionID
  }

  private func scheduleReceive() async {
    await self.websocket?.receive { @Sendable result in
      Task { await self.receiveMessage(result) }
    }
  }

  private func receiveMessage(
    _ result: Result<URLSessionWebSocketTask.Message, any Error>
  ) async {
    switch result {
    case .success(let message):
      // reset the keepalive timer on every message
      await self.keepaliveTimer?.reset()

      if let message = parseMessage(message) {
        // ignore duplicate messages
        if !receivedMessageIDs.contains(message.id) {
          await handleMessage(message)
          receivedMessageIDs.append(message.id)

          // only keep the last 100 message IDs
          if receivedMessageIDs.count > 100 {
            receivedMessageIDs.removeFirst()
          }
        }
      }

      // recursively receive the next message
      await self.scheduleReceive()
    case .failure(let error):
      await keepaliveTimer?.cancel()

      if isClosing { return }

      let disconnectedError = EventSubConnectionError.disconnected(
        with: error, socketID: socketID ?? "")

      self.finishWelcome(.failure(disconnectedError))

      await self.keepaliveTimer?.cancel()
      await onMessage(.failure(disconnectedError))
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

  private func handleMessage(_ message: EventSubMessage) async {
    switch message.payload {
    case .keepalive: break  // nothing to do for keepalive messages
    case .welcome(let welcome):
      self.finishWelcome(.success(welcome))
    case .notification(let notification):
      await onMessage(.success(notification))
    case .revocation(let revocation):
      await onMessage(.failure(EventSubConnectionError.revocation(revocation)))
    case .reconnect(let reconnect):
      await onMessage(
        .failure(
          EventSubConnectionError.reconnectRequested(
            reconnectURL: reconnect.reconnectURL, socketID: socketID ?? "")))
    }
  }

  private func finishWelcome(
    _ result: Result<EventSubWelcome, EventSubConnectionError>
  ) {
    if let continuation = self.welcomeContinuation {
      self.welcomeContinuation = nil
      switch result {
      case .success(let welcome):
        continuation.resume(returning: welcome)
      case .failure(let err):
        continuation.resume(throwing: err)
      }
    } else {
      pendingWelcomeResult = result
    }
  }

  private func handleKeepaliveTimeout() async {
    // NOTE: onMessage needs to be async because of this call, since the keepalive timer
    // runs in a different thread, this call would otherwise cross actor boundaries. Swift
    // Strict Concurrency checking cannot verify this at the moment, because the actor
    // isolation gets erased in `EventSubClient` when passing an instance method as the
    // handler to the connection.
    await self.onMessage(
      .failure(EventSubConnectionError.timedOut(socketID: self.socketID ?? "")))
    await self.websocket?.cancel(with: .goingAway, reason: nil)

    self.finishWelcome(
      .failure(EventSubConnectionError.timedOut(socketID: self.socketID ?? "")))
  }
}
