import Foundation
import TwitchIRC

internal enum IRCConnectionUpdate: Sendable {
  case state(IRCState)
  case message(IncomingMessage)
}

internal actor IRCConnectionSupervisor {
  nonisolated let id = UUID()

  let connection: IRCConnection
  let role: IRCRecovery.Role
  private let lifetime = IRCConnectionLifetime()

  var state: State { currentState }
  private var currentState = State() {
    didSet {
      continuation?.yield(.state(state.snapshot))
      completeConnectionWaiters()
    }
  }

  var connectionAttemptID = UUID()

  private var runTask: Task<Void, Never>?
  var interruptionReason: IRCRecovery.Reason?
  var continuation: AsyncThrowingStream<IRCConnectionUpdate, any Error>.Continuation?
  var connectionWaiters: [UUID: AsyncThrowingStream<Void, any Error>.Continuation] = [:]

  init(
    credentials: TwitchCredentials? = nil,
    network: NetworkSession,
    role: IRCRecovery.Role,
    rateLimiter: IRCAccountRateLimiter = .shared
  ) {
    self.connection = IRCConnection(
      credentials: credentials,
      network: network,
      rateLimiter: rateLimiter, lifetime: lifetime)

    self.role = role
  }

  deinit {
    runTask?.cancel()
    continuation?.finish()

    for waiter in connectionWaiters.values { waiter.finish(throwing: IRCError.disconnected) }

    let connection = connection
    Task.detached { await connection.disconnect() }
  }

  nonisolated func invalidate() { lifetime.invalidate() }

  func start() throws -> AsyncThrowingStream<IRCConnectionUpdate, any Error> {
    guard !state.isEnded else { throw state.terminalError ?? IRCError.disconnected }
    guard state.status == .idle else { throw IRCInternalError.alreadyConnected }
    try lifetime.check()

    let (stream, continuation) = AsyncThrowingStream<IRCConnectionUpdate, any Error>.makeStream()
    self.continuation = continuation

    updateState { $0.status = .connecting }

    runTask = Task { [weak self] in await self?.run() }

    return stream
  }

  func send(_ message: OutgoingMessage) async throws {
    try await send(IRCWireMessage(message))
  }

  func send(
    _ message: IRCWireMessage,
    beforeDispatch: (@Sendable (IRCConnectionLifetime) async throws -> Void)? = nil
  ) async throws {
    try lifetime.check()
    guard state.status == .connected else {
      throw state.terminalError ?? IRCError.disconnected
    }

    let attemptID = connectionAttemptID

    do {
      try await connection.send(message, beforeDispatch: beforeDispatch)
    } catch let refusal as IRCDispatchRefused {
      throw refusal.underlying
    } catch let error as CancellationError {
      throw error
    } catch {
      if connectionAttemptID == attemptID, state.status == .connected {
        interruptionReason = .init(error: error)
        await connection.disconnect()
      }

      throw error
    }
  }

  func disconnect(throwing error: Error? = nil) async {
    guard !state.isEnded else { return }
    invalidate()

    updateState { state in
      state.terminalError = error
      state.status =
        if let error { .failed(.init(terminalError: error)) } else { .shutdown }
      state.recovery = nil
    }

    runTask?.cancel()
    runTask = nil

    continuation?.finish(throwing: error)
    continuation = nil

    await connection.disconnect()
  }

  func updateState(_ update: (inout State) -> Void) {
    var state = currentState
    update(&state)
    currentState = state
  }
}
