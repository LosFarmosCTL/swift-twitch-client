import Foundation
import TwitchIRC

internal actor IRCConnectionPool {
  private let network: NetworkSession

  let credentials: TwitchCredentials?
  let rateLimiter: IRCAccountRateLimiter
  let joinTimeout: Duration

  var state: State { currentState }
  private var currentState = State() {
    didSet {
      if !updatingChannels { publishState() }
    }
  }

  var pendingJoins: [String: PendingJoin] = [:]
  var updates: AsyncThrowingStream<IRCConnectionUpdate, any Error>.Continuation?
  private var updatingChannels = false
  private var disconnectTask: Task<Void, Never>?

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

  deinit {
    for pending in pendingJoins.values { pending.task.cancel() }
  }

  func start() throws -> AsyncThrowingStream<IRCConnectionUpdate, any Error> {
    try Task.checkCancellation()
    guard !state.ended else { throw state.terminalError ?? IRCError.disconnected }
    guard !state.active else { throw IRCInternalError.alreadyConnected }

    let (stream, continuation) = AsyncThrowingStream<IRCConnectionUpdate, any Error>.makeStream()
    updates = continuation
    updateState { $0.active = true }

    for id in state.entries.keys { startRelay(id) }
    return stream
  }

  func setChannels(_ channels: [String], retrying: Set<String> = []) throws {
    guard !state.ended else { throw IRCError.disconnected }
    updatingChannels = true
    defer {
      updatingChannels = false
      // Even an unchanged channel set may have a new managed readiness waiter.
      publishState()
    }

    let desired = Set(channels.map(IRCWireMessage.channelLogin))
    for channel in Set(state.statuses.keys).subtracting(desired) {
      try part(from: channel)
    }
    for channel in desired.subtracting(state.statuses.keys) {
      try join(to: channel)
    }
    for channel in retrying {
      try retryChannel(channel)
    }
  }

  private func publishState() {
    updates?.yield(.state(snapshot))
  }

  func disconnect(throwing error: Error? = nil) async {
    if let disconnectTask {
      await disconnectTask.value
      return
    }

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

    updates?.finish(throwing: error)
    updates = nil

    for entry in oldEntries.values { entry.task?.cancel() }

    let task = Task {
      for entry in oldEntries.values { await entry.supervisor.disconnect() }
    }

    disconnectTask = task
    await task.value
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
