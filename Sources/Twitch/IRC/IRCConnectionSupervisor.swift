import Foundation
import TwitchIRC

internal actor IRCConnectionSupervisor {
  enum Event: Sendable {
    case state(IRCState)
    case message(IncomingMessage)
  }

  nonisolated let id = UUID()

  private let connection: IRCConnection
  private let role: IRCRecovery.Role

  var state: State { currentState }
  private var currentState = State() {
    didSet {
      let snapshot = snapshot
      continuation?.yield(.state(snapshot))

      for observer in stateObservers.values {
        observer.yield(snapshot)
      }
    }
  }

  private var connectionAttemptID = UUID()

  private var task: Task<Void, Never>?
  private var interruptionReason: IRCRecovery.Reason?
  private var continuation: AsyncThrowingStream<Event, Error>.Continuation?
  var stateObservers: [UUID: AsyncStream<IRCState>.Continuation] = [:]

  init(
    credentials: TwitchCredentials? = nil,
    network: NetworkSession,
    role: IRCRecovery.Role,
    rateLimiter: IRCAccountRateLimiter = .shared
  ) {
    self.connection = IRCConnection(
      credentials: credentials,
      network: network,
      rateLimiter: rateLimiter)

    self.role = role
  }

  deinit {
    task?.cancel()
    continuation?.finish()

    for observer in stateObservers.values { observer.finish() }

    let connection = connection
    Task.detached { await connection.disconnect() }
  }

  func start() throws -> AsyncThrowingStream<Event, Error> {
    guard !state.isEnded else { throw state.terminalError ?? IRCError.disconnected }
    guard state.status == .idle else { throw IRCError.alreadyConnected }

    let (stream, continuation) = AsyncThrowingStream<Event, Error>.makeStream()
    self.continuation = continuation

    updateState { $0.status = .connecting }

    task = Task { [weak self] in await self?.run() }

    return stream
  }

  func waitUntilConnected() async throws {
    let updates = stateUpdates()

    try await withTaskCancellationHandler {
      for await _ in updates {
        switch state.status {
        case .connected:
          try Task.checkCancellation()
          return

        case .failed: throw state.terminalError ?? IRCError.disconnected
        case .shutdown: throw IRCError.disconnected
        default: break
        }
      }

      try Task.checkCancellation()
      throw IRCError.disconnected
    } onCancel: {
      Task { await self.disconnect() }
    }
  }

  func send(_ message: OutgoingMessage) async throws {
    guard state.status == .connected else {
      throw state.terminalError ?? IRCError.disconnected
    }

    let attemptID = connectionAttemptID

    do {
      try await connection.send(message)
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

    updateState { state in
      state.terminalError = error
      state.status =
        if let error { .failed(.init(terminalError: error)) } else { .shutdown }
      state.recovery = nil
    }

    task?.cancel()
    task = nil

    continuation?.finish(throwing: error)
    continuation = nil

    finishStateObservers()

    await connection.disconnect()
  }

  private func updateState(_ update: (inout State) -> Void) {
    var state = currentState
    update(&state)
    currentState = state
  }
}

extension IRCConnectionSupervisor {
  private func run() async {
    var failures = 0

    while !state.isEnded {
      let reason: IRCRecovery.Reason

      do {
        connectionAttemptID = UUID()

        if state.recovery?.retryAt != nil {
          updateState { $0.recovery?.retryAt = nil }
        }

        let stream = try await connection.connect()

        guard !state.isEnded else { return }

        failures = 0
        updateState { state in
          state.status = .connected
          state.recovery = nil
        }

        reason = try await relay(stream)
      } catch {
        switch error {
        case IRCError.loginFailed:
          await disconnect(throwing: error)
          return
        default:
          reason = .init(error: error)
        }
      }

      guard !state.isEnded else { return }

      failures += 1

      let delay = scheduleRecovery(
        reason: interruptionReason ?? reason,
        failures: failures
      )

      interruptionReason = nil
      await connection.disconnect()

      do { try await Task.sleep(for: delay) } catch { return }
    }
  }

  private func relay(
    _ stream: AsyncThrowingStream<IncomingMessage, Error>
  ) async throws -> IRCRecovery.Reason {
    for try await message in stream {
      guard !state.isEnded else { return .connectionClosed }

      if case .reconnect = message { return .serverRequestedReconnect }
      if case .globalUserState(let state) = message {
        updateState { $0.globalUserState = state }
      }

      continuation?.yield(.message(message))
    }

    return .connectionClosed
  }

  private func scheduleRecovery(
    reason: IRCRecovery.Reason,
    failures: Int
  ) -> Duration {
    let delay = Self.reconnectDelay(failures: failures)

    updateState { state in
      state.status = .reconnecting
      state.recovery = IRCRecovery(
        connectionID: id,
        role: role,
        channels: [],
        reason: reason,
        attempt: failures,
        retryAt: Date().addingTimeInterval(
          Double(delay.components.seconds) + Double(delay.components.attoseconds) / 1e18))
    }

    return delay
  }

  private static func reconnectDelay(failures: Int) -> Duration {
    let ceiling = 250 * (1 << min(max(failures, 1), 6))

    return .milliseconds(Int.random(in: (ceiling / 2)...ceiling))
  }
}
