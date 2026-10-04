import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor TwitchIRCClient {
  enum TerminalState {
    case finished
    case failed(Error)
  }

  public enum AuthenticationStyle: Sendable {
    case anonymous
    case authenticated(_ credentials: TwitchCredentials)
  }

  public enum Mode: Sendable {
    case receiveOnly
    case readWrite
  }

  public var state: IRCState { currentState }
  private var currentState = IRCState() {
    didSet {
      for observer in stateObservers.values {
        observer.yield(currentState)
      }
    }
  }

  let writeConnection: IRCConnectionSupervisor?
  let readConnectionPool: IRCConnectionPool

  var stateObservers: [UUID: AsyncStream<IRCState>.Continuation] = [:]
  var readState = IRCState()
  var writeState = IRCState()

  var handlers = [IRCMessageHandler]()

  var readStateTask: Task<Void, Never>?
  var writeStateTask: Task<Void, Never>?
  private var messageTask: Task<Void, Never>?
  private var writeTask: Task<Void, Never>?

  private(set) var started = false
  var terminalState: TerminalState?

  public init(
    _ authenticationStyle: AuthenticationStyle,
    mode: Mode = .readWrite,
    urlSession: URLSession = .shared
  ) {
    self.init(
      authenticationStyle,
      mode: mode,
      network: URLSessionNetworkSession(session: urlSession))
  }

  internal init(
    _ authenticationStyle: AuthenticationStyle,
    mode: Mode = .readWrite,
    network: NetworkSession
  ) {
    let credentials: TwitchCredentials? =
      switch authenticationStyle {
      case .authenticated(let credentials): credentials
      case .anonymous: nil
      }

    self.writeConnection =
      if mode == .readWrite {
        IRCConnectionSupervisor(
          credentials: credentials,
          network: network,
          role: .write)
      } else { nil }

    self.readConnectionPool = IRCConnectionPool(with: credentials, network: network)

    Task { [weak self] in await self?.observeConnectionStates() }
  }

  public func connect() async throws {
    try throwIfDisconnected()
    try Task.checkCancellation()
    guard !started else { throw IRCError.alreadyConnected }

    started = true
    updateState { state in state.status = .connecting }

    do {
      try await establishConnections()
      try Task.checkCancellation()
      try throwIfDisconnected()
    } catch {
      if case .failed(let failure) = terminalState { throw failure }

      if Task.isCancelled || error is CancellationError {
        await shutdown()
        throw CancellationError()
      }

      try throwIfDisconnected()
      await handleMessageStreamFailure(error)
      throw error
    }
  }

  private func establishConnections() async throws {
    if let writeConnection {
      let stream = try await writeConnection.start()
      try throwIfDisconnected()

      writeTask = Task { [weak self] in
        do { for try await _ in stream {} } catch {
          await self?.handleMessageStreamFailure(error)
        }
      }

      try await writeConnection.waitUntilConnected()
      try throwIfDisconnected()
    }

    let stream = try await readConnectionPool.start()
    try throwIfDisconnected()

    messageTask = Task { [weak self] in
      do {
        for try await message in stream { await self?.yield(message) }
      } catch {
        await self?.handleMessageStreamFailure(error)
      }
    }

    try await readConnectionPool.waitUntilConnected()
  }

  deinit {
    messageTask?.cancel()
    writeTask?.cancel()
    readStateTask?.cancel()
    writeStateTask?.cancel()

    for observer in stateObservers.values { observer.finish() }
    for handler in handlers { handler.finish() }

    let writeConnection = writeConnection
    let readConnectionPool = readConnectionPool

    Task.detached {
      await writeConnection?.disconnect()
      await readConnectionPool.disconnect()
    }
  }

  public func shutdown() async {
    guard terminalState == nil else { return }

    terminalState = .finished
    stopTasks()

    updateState { state in
      state.status = .shutdown
      state.channels = [:]
      state.recoveries = []
    }

    finishStateObservers()
    finishHandlers()

    await writeConnection?.disconnect()
    await readConnectionPool.disconnect()
  }

  public func setDesiredChannels(_ channels: [String]) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.setChannels(channels)
  }

  public func requestJoin(to channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.join(to: channel)
  }

  public func requestPart(from channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.part(from: channel)
  }

  public func retryChannel(_ channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.retryChannel(channel)
  }

  public func sendMessage(
    _ message: String,
    to channel: String,
    replyTo replyMessageID: String? = nil,
    clientNonce: String? = nil
  ) async throws {
    try throwIfDisconnected()

    guard let writeConnection else {
      throw IRCError.writeConnectionNotEnabled
    }

    try await writeConnection.send(
      .privateMessage(
        to: channel,
        message: message,
        messageIdToReply: replyMessageID,
        clientNonce: clientNonce
      )
    )
  }

  private func throwIfDisconnected() throws {
    if let terminalState {
      switch terminalState {
      case .finished:
        throw IRCError.disconnected
      case .failed(let error):
        throw error
      }
    }
  }

  private func handleMessageStreamFailure(_ error: Error) async {
    guard terminalState == nil else { return }

    terminalState = .failed(error)
    stopTasks()

    let failure = IRCChannelFailure(terminalError: error)
    updateState { state in
      state.status = .failed(failure)
      state.channels = state.channels.mapValues { _ in .failed(failure) }
      state.recoveries = []
    }

    finishStateObservers()
    finishHandlers(throwing: error)

    await writeConnection?.disconnect(throwing: error)
    await readConnectionPool.disconnect(throwing: error)
  }
}

extension TwitchIRCClient {
  func updateState(_ update: (inout IRCState) -> Void) {
    var state = currentState
    update(&state)
    currentState = state
  }

  fileprivate func stopTasks() {
    messageTask?.cancel()
    messageTask = nil

    writeTask?.cancel()
    writeTask = nil

    readStateTask?.cancel()
    readStateTask = nil

    writeStateTask?.cancel()
    writeStateTask = nil
  }
}
