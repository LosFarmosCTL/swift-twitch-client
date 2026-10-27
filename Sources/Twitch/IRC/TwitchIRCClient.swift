import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// An independently owned Twitch IRC session for receiving and optionally sending chat.
///
/// Register message observers before calling `connect()` so they can receive messages
/// during startup. Configure membership with `setDesiredChannels(_:)`. The session
/// manages connection pooling and recovery until `shutdown()` or a terminal failure. A
/// terminated session cannot be restarted.
public actor TwitchIRCClient {
  enum TerminalState {
    case finished
    case failed(Error)
  }

  /// Whether an IRC session connects anonymously or with Twitch account credentials.
  public enum AuthenticationStyle: Sendable {
    /// No authenticated user identity is supplied.
    case anonymous
    /// Authenticates using the associated Twitch account credentials.
    case authenticated(_ credentials: TwitchCredentials)
  }

  /// Whether an IRC session only receives messages or also has a write connection.
  public enum Mode: Sendable {
    /// Creates read connections for incoming messages without a write connection.
    case receiveOnly
    /// Creates read connections and a separate connection for sending messages.
    case readWrite
  }

  /// The latest snapshot of connectivity, channel membership, and recovery progress.
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

  private let authenticationStyle: AuthenticationStyle

  private(set) var started = false
  var terminalState: TerminalState?

  /// Creates an unconnected IRC session.
  ///
  /// Configure desired channels and observers, then call `connect()` to start the
  /// session.
  ///
  /// - Parameters:
  ///   - authenticationStyle: Whether to connect anonymously or with account credentials.
  ///   - mode: Whether to create a receive-only session or also enable sending. Defaults
  ///     to `.readWrite`.
  ///   - urlSession: The URL session used for network requests. Defaults to `.shared`.
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
    self.authenticationStyle = authenticationStyle
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

  /// Starts the IRC session and waits for its initial connections to become ready.
  ///
  /// Configure desired channels and register observers before connecting. Healthy
  /// connections may deliver messages while other connections are still starting.
  /// Cancelling startup shuts down the session.
  ///
  /// - Throws: `TwitchAuthenticationError.userAccessTokenRequired` for app credentials,
  ///   `IRCError.alreadyConnected` if startup has already begun, a terminal
  ///   session error, a connection error, or `CancellationError`.
  public func connect() async throws {
    try throwIfDisconnected()
    try Task.checkCancellation()
    guard !started else { throw IRCError.alreadyConnected }
    if case .authenticated(let credentials) = authenticationStyle {
      _ = try credentials.requireUser()
    }

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

  /// Permanently shuts down the IRC session and finishes its observers.
  ///
  /// Disconnects read and write connections, clears channel and recovery state, and
  /// finishes message consumers normally. Repeated calls have no effect. Create a new
  /// session to connect again.
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

  /// Replaces the full set of channels the IRC session should receive.
  ///
  /// May be called before connecting. While active, the session joins new channels and
  /// parts removed channels.
  ///
  /// Channel login names are lowercased and stripped of leading `#` characters. Duplicate
  /// names are combined. Returning confirms the local membership request, before Twitch
  /// acknowledges it. Observe `stateUpdates()` for channel progress and failures.
  ///
  /// - Throws: A terminal session error or an error updating channel membership.
  ///
  /// - Parameters:
  ///   - channels: The complete list of desired channel login names.
  public func setDesiredChannels(_ channels: [String]) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.setChannels(channels)
  }

  /// Adds a channel to the IRC session’s desired membership.
  ///
  /// Channel login names are lowercased and stripped of leading `#` characters. Returning
  /// confirms the local membership request, before Twitch acknowledges it. Observe
  /// `stateUpdates()` for channel progress and failures.
  ///
  /// - Throws: A terminal session error or an error requesting membership.
  ///
  /// - Parameters:
  ///   - channel: The channel’s login name.
  public func requestJoin(to channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.join(to: channel)
  }

  /// Removes a channel from the IRC session’s desired membership.
  ///
  /// Channel login names are lowercased and stripped of leading `#` characters. Returning
  /// confirms the local membership request, before Twitch acknowledges it. Observe
  /// `stateUpdates()` for channel progress and failures.
  ///
  /// - Throws: A terminal session error or an error updating membership.
  ///
  /// - Parameters:
  ///   - channel: The channel’s login name.
  public func requestPart(from channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.part(from: channel)
  }

  /// Requests another join attempt for a channel that failed to join.
  ///
  /// Channel login names are lowercased and stripped of leading `#` characters. This is a
  /// no-op unless the channel is currently in a failed state. Returning confirms the
  /// local membership request, before Twitch acknowledges it. Observe `stateUpdates()`
  /// for channel progress and failures.
  ///
  /// - Throws: A terminal session error or an error retrying channel membership.
  ///
  /// - Parameters:
  ///   - channel: The channel’s login name.
  public func retryChannel(_ channel: String) async throws {
    try throwIfDisconnected()
    try await readConnectionPool.retryChannel(channel)
  }

  /// Sends a chat message using the IRC session’s write connection.
  ///
  /// The channel name is lowercased and stripped of leading `#` characters. Successful
  /// sending does not confirm that Twitch delivered the message to viewers.
  ///
  /// - Throws: `IRCError.writeConnectionNotEnabled` for a receive-only session, a
  ///   terminal session error, or an error sending the message.
  ///
  /// - Parameters:
  ///   - message: The chat text to send.
  ///   - channel: The channel’s login name.
  ///   - replyToMessageID: The ID of the message to reply to; `nil` sends a top-level
  ///     message.
  ///   - clientNonce: An optional nonce used to correlate the outgoing IRC message.
  public func sendMessage(
    _ message: String,
    to channel: String,
    replyTo replyToMessageID: String? = nil,
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
        messageIdToReply: replyToMessageID,
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
