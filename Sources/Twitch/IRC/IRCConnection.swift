import Foundation
import TwitchIRC

internal actor IRCConnection {
  private static let tmiURL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let network: NetworkSession
  private let handshakeTimeout: Duration
  private let rateLimiter: IRCAccountRateLimiter
  private let lifetime: IRCConnectionLifetime

  private var authenticationTask: Task<Void, Error>?
  private var receiveTask: Task<Void, Never>?

  private var connectionAttemptID = UUID()
  private var connecting = false
  private var webSocket: WebSocketTask?
  private var dispatchPermit: IRCConnectionLifetime?

  init(
    credentials: TwitchCredentials? = nil,
    network: NetworkSession,
    handshakeTimeout: Duration = .seconds(15),
    rateLimiter: IRCAccountRateLimiter = .shared,
    lifetime: IRCConnectionLifetime = .init()
  ) {
    self.credentials = credentials
    self.network = network
    self.handshakeTimeout = handshakeTimeout
    self.rateLimiter = rateLimiter
    self.lifetime = lifetime
  }

  deinit {
    authenticationTask?.cancel()
    receiveTask?.cancel()

    let webSocket = webSocket
    Task.detached { await webSocket?.cancel(with: .goingAway, reason: nil) }
  }

  func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error> {
    guard !connecting, webSocket == nil else { throw IRCInternalError.alreadyConnected }
    try lifetime.check()
    if let credentials { try IRCWireMessage.validateCredentials(credentials) }

    connecting = true
    let attemptID = connectionAttemptID

    do {
      let socket = try await openSocket(for: attemptID)
      try await paceAuthentication()
      try checkAttempt(attemptID)
      authenticationTask = nil

      let buffered = try await Self.handshake(
        on: socket, credentials: credentials, timeout: handshakeTimeout, lifetime: lifetime)
      try checkAttempt(attemptID)

      connecting = false
      dispatchPermit = IRCConnectionLifetime()

      return receiveMessages(on: socket, attemptID: attemptID, buffered: buffered)
    } catch {
      await close(attemptID: attemptID)
      try Task.checkCancellation()
      throw error
    }
  }

  private func openSocket(for attemptID: UUID) async throws -> WebSocketTask {
    let socket = await network.webSocketTask(with: Self.tmiURL)
    guard attemptID == connectionAttemptID else {
      await socket.cancel(with: .goingAway, reason: nil)
      throw CancellationError()
    }

    webSocket = socket
    try lifetime.check()
    return socket
  }

  private func checkAttempt(_ id: UUID) throws {
    try lifetime.check()
    guard id == connectionAttemptID else { throw IRCError.disconnected }
  }

  private func paceAuthentication() async throws {
    guard let credentials else { return }

    let task = Task { [rateLimiter] in
      try await rateLimiter.acquire(
        account: try credentials.requireUser().id, operation: .authenticate)
    }

    authenticationTask = task

    try await withTaskCancellationHandler {
      try await task.value
      try Task.checkCancellation()
    } onCancel: {
      task.cancel()
    }
  }

  // MARK: - Receiving

  private func receiveMessages(
    on socket: WebSocketTask,
    attemptID: UUID,
    buffered: [IncomingMessage]
  ) -> AsyncThrowingStream<IncomingMessage, Error> {
    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()

    for message in buffered { continuation.yield(message) }

    receiveTask = Task { [weak self] in
      do {
        while !Task.isCancelled {
          for message in try await Self.receive(on: socket) {
            continuation.yield(message)
          }
        }

        continuation.finish()
      } catch {
        if Task.isCancelled {
          continuation.finish()
        } else {
          continuation.finish(throwing: error)
        }
      }

      await self?.close(attemptID: attemptID)
    }

    return stream
  }

  // MARK: - Sending

  func send(_ message: OutgoingMessage) async throws {
    try await send(IRCWireMessage(message))
  }

  func send(
    _ message: IRCWireMessage,
    beforeDispatch: (@Sendable (IRCConnectionLifetime) async throws -> Void)? = nil
  ) async throws {
    try lifetime.check()
    guard let webSocket, let dispatchPermit else { throw IRCError.disconnected }

    if let beforeDispatch {
      do { try await beforeDispatch(dispatchPermit) } catch {
        throw IRCDispatchRefused(underlying: error)
      }
    }
    // A committed dispatch always targets the captured socket, even if it races
    // the next connection. Transport errors after this point remain counted.
    try await webSocket.send(.string(message.text))
  }

  // MARK: - Shutdown

  func disconnect() async {
    connectionAttemptID = UUID()
    connecting = false
    dispatchPermit?.invalidate()
    dispatchPermit = nil

    let socket = webSocket
    webSocket = nil

    authenticationTask?.cancel()
    authenticationTask = nil

    receiveTask?.cancel()
    receiveTask = nil

    await socket?.cancel(with: .goingAway, reason: nil)
  }

  private func close(attemptID: UUID) async {
    guard connectionAttemptID == attemptID else { return }
    await disconnect()
  }
}
