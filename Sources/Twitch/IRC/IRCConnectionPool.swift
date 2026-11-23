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
      if batchingStateUpdates {
        stateDirtyDuringBatch = true
      } else {
        publishState()
      }
    }
  }

  var pendingJoins: [String: PendingJoin] = [:]
  var updates: AsyncThrowingStream<Update, any Error>.Continuation?
  private var batchingStateUpdates = false
  private var stateDirtyDuringBatch = false
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

  func start() throws -> AsyncThrowingStream<Update, any Error> {
    try Task.checkCancellation()
    guard !state.ended else { throw state.terminalError ?? IRCError.disconnected }
    guard !state.active else { throw IRCInternalError.alreadyConnected }

    let (stream, continuation) = AsyncThrowingStream<Update, any Error>.makeStream()
    updates = continuation
    updateState { $0.active = true }

    for id in state.entries.keys { startRelay(id) }
    return stream
  }

  func setChannels(_ logins: [String], retrying: Set<String> = []) throws {
    try setTargets(logins.map { ChannelTarget(login: $0) }, retrying: retrying)
  }

  func setTargets(_ targets: [ChannelTarget], retrying: Set<String> = []) throws {
    guard !state.ended else { throw IRCError.disconnected }

    // Publish even when unchanged so newly attached readiness waiters observe current status.
    try batchStateUpdates(publishAlways: true) {
      let desired = Dictionary(
        targets.map { ($0.login, $0) },
        uniquingKeysWith: { _, latest in latest })
      let explicitRetries = Set(retrying.map(IRCWireMessage.channelLogin))

      for (login, existing) in state.channels {
        guard let target = desired[login], target.expectedRoomID == existing.expectedRoomID else {
          try part(from: login)
          continue
        }
      }

      for (login, target) in desired {
        if let existing = state.channels[login] {
          try reconcileExistingChannel(
            login, existing: existing, target: target,
            explicitRetry: explicitRetries.contains(login))
        } else {
          try join(target)
        }
      }
    }
  }

  private func reconcileExistingChannel(
    _ login: String,
    existing: ChannelState,
    target: ChannelTarget,
    explicitRetry: Bool
  ) throws {
    let tokenChanged = target.token != nil && existing.token != target.token
    if tokenChanged {
      updateState { $0.channels[login]?.token = target.token }
    }

    if explicitRetry || (tokenChanged && existing.status.isFailed) {
      try retryChannel(login)
    }
  }

  func batchStateUpdates(
    publishAlways: Bool = false,
    _ body: () throws -> Void
  ) rethrows {
    let wasBatching = batchingStateUpdates
    batchingStateUpdates = true
    defer {
      batchingStateUpdates = wasBatching
      if !wasBatching, publishAlways || stateDirtyDuringBatch {
        stateDirtyDuringBatch = false
        publishState()
      }
    }
    try body()
  }

  private func publishState() {
    updates?.yield(.state(state.poolState))
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
        let failure = IRCChannelFailure(terminalError: error)
        state.channels = state.channels.mapValues { channel in
          var updated = channel
          updated.status = .failed(failure)
          return updated
        }
      } else {
        state.channels.removeAll()
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
