import Foundation
import TwitchIRC

internal actor IRCConnectionPool {
  struct Entry: Sendable {
    let supervisor: IRCConnectionSupervisor

    var channels: Set<String> = []
    var ready = false
    var recovery: IRCRecovery?
    var globalUserState: GlobalUserState?
    var task: Task<Void, Never>?
  }

  struct PendingJoin {
    let token: UUID
    let task: Task<Void, Never>
  }

  private let network: NetworkSession

  let credentials: TwitchCredentials?
  let rateLimiter: IRCAccountRateLimiter
  let joinTimeout: Duration

  var state: State { currentState }
  private var currentState = State() {
    didSet {
      let snapshot = snapshot
      for observer in stateObservers.values { observer.yield(snapshot) }
    }
  }

  var pendingJoins: [String: PendingJoin] = [:]
  private(set) var established = false

  var continuation: AsyncThrowingStream<IncomingMessage, Error>.Continuation?
  var stateObservers: [UUID: AsyncStream<IRCState>.Continuation] = [:]

  init(
    with credentials: TwitchCredentials? = nil,
    network: NetworkSession,
    joinTimeout: Duration = .seconds(15),
    rateLimiter: IRCAccountRateLimiter = .shared
  ) {
    self.credentials = credentials
    self.network = network
    self.joinTimeout = joinTimeout
    self.rateLimiter = rateLimiter
  }

  func start() throws -> AsyncThrowingStream<IncomingMessage, Error> {
    try Task.checkCancellation()

    guard !state.ended else { throw state.terminalError ?? IRCError.disconnected }
    guard !state.active else { throw IRCError.alreadyConnected }

    let (stream, continuation) = AsyncThrowingStream<IncomingMessage, Error>.makeStream()
    self.continuation = continuation

    updateState { state in
      state.active = true

      if state.entries.isEmpty {
        _ = addEntry(to: &state)
      }
    }

    for id in state.entries.keys { startRelay(id) }

    return stream
  }

  func waitUntilConnected() async throws {
    let updates = stateUpdates()
    try await withTaskCancellationHandler {
      for await _ in updates {
        try Task.checkCancellation()

        switch snapshot.status {
        case .connected:
          established = true
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

  func disconnect(throwing error: Error? = nil) async {
    guard !state.ended else { return }

    for channel in Array(pendingJoins.keys) { cancelJoin(channel) }

    let oldEntries = state.entries

    updateState { state in
      state.ended = true
      state.active = false
      state.terminalError = error
      state.entries.removeAll()
      state.userStateConnectionID = nil

      if let error {
        state.statuses = state.statuses.mapValues { _ in
          .failed(.init(terminalError: error))
        }
      } else {
        state.statuses.removeAll()
      }
    }

    finishStateObservers()

    continuation?.finish(throwing: error)
    continuation = nil

    for entry in oldEntries.values { entry.task?.cancel() }
    for entry in oldEntries.values { await entry.supervisor.disconnect() }
  }

  func addEntry(to state: inout State) -> UUID {
    let supervisor = IRCConnectionSupervisor(
      credentials: credentials,
      network: network,
      role: .read,
      rateLimiter: rateLimiter)

    let id = supervisor.id
    state.entries[id] = Entry(supervisor: supervisor)

    if state.userStateConnectionID == nil {
      state.userStateConnectionID = id
    }

    return id
  }

  @discardableResult
  func updateState<Result>(_ update: (inout State) -> Result) -> Result {
    var state = currentState
    let result = update(&state)
    currentState = state
    return result
  }
}
