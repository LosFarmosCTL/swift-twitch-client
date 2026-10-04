import Foundation
import TwitchIRC

internal actor IRCConnection {
  private static let tmiURL = URL(string: "wss://irc-ws.chat.twitch.tv:443")!

  private let credentials: TwitchCredentials?
  private let network: NetworkSession
  private let handshakeTimeout: Duration
  private let rateLimiter: IRCAccountRateLimiter

  private var authenticationTask: Task<Void, Error>?
  private var receiveTask: Task<Void, Never>?

  private var connectionAttemptID = UUID()
  private var connecting = false
  private var websocket: WebSocketTask?

  init(
    credentials: TwitchCredentials? = nil,
    network: NetworkSession,
    handshakeTimeout: Duration = .seconds(15),
    rateLimiter: IRCAccountRateLimiter = .shared
  ) {
    self.credentials = credentials
    self.network = network
    self.handshakeTimeout = handshakeTimeout
    self.rateLimiter = rateLimiter
  }

  deinit {
    authenticationTask?.cancel()
    receiveTask?.cancel()

    let websocket = websocket
    Task.detached { await websocket?.cancel(with: .goingAway, reason: nil) }
  }

  func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error> {
    guard !connecting else { throw IRCError.alreadyConnected }
    guard websocket == nil else { throw IRCError.alreadyConnected }

    connecting = true
    let attemptID = connectionAttemptID

    let socket = await network.webSocketTask(with: Self.tmiURL)

    guard attemptID == connectionAttemptID else {
      await socket.cancel(with: .goingAway, reason: nil)
      throw CancellationError()
    }

    websocket = socket

    do {
      try Task.checkCancellation()
      try await paceAuthentication()

      guard attemptID == connectionAttemptID else { throw IRCError.disconnected }

      authenticationTask = nil

      let buffered = try await Self.handshake(
        on: socket, credentials: credentials, timeout: handshakeTimeout)
      try Task.checkCancellation()

      guard attemptID == connectionAttemptID else { throw IRCError.disconnected }

      connecting = false

      return receiveMessages(on: socket, attemptID: attemptID, buffered: buffered)
    } catch {
      await close(attemptID: attemptID)
      try Task.checkCancellation()
      throw error
    }
  }

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

  func send(_ message: OutgoingMessage) async throws {
    try Task.checkCancellation()

    guard let websocket else { throw IRCError.disconnected }
    guard !connecting else { throw IRCError.disconnected }

    try await websocket.send(.string(message.serialize()))
  }

  func disconnect() async {
    connectionAttemptID = UUID()
    connecting = false

    let socket = websocket
    websocket = nil

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

  private func paceAuthentication() async throws {
    guard let credentials else { return }

    let task = Task { [rateLimiter] in
      try await rateLimiter.acquire(account: credentials.userID, operation: .authenticate)
    }

    authenticationTask = task

    try await withTaskCancellationHandler {
      try await task.value
      try Task.checkCancellation()
    } onCancel: {
      task.cancel()
    }
  }
}
