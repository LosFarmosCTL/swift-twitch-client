import Foundation

extension TwitchClient {
  /// The latest snapshot of managed chat membership, transport status, and send eligibility.
  ///
  /// Reading this property never opens a connection. To observe changes over time, use
  /// ``chatStateUpdates()``.
  ///
  /// - SeeAlso: <doc:ManagedChat>, ``ChatState``
  public var chatState: ChatState { chat.snapshot }

  /// Registers an independent stream of normalized managed chat events.
  ///
  /// Register a stream **before** joining channels so you do not miss initial room-state
  /// or early chat events. Calling this method does not open any transport. Cancelling
  /// the observer leaves channel memberships intact; the stream finishes when
  /// ``shutdownChat()`` is called.
  ///
  /// - Parameter bufferingPolicy: How to buffer unread events. Defaults to `.unbounded`.
  ///   Explicit bounded policies cap memory by dropping events without slowing the reader.
  /// - Returns: An async stream of ``ChatEvent`` values from all joined channels.
  /// - SeeAlso: <doc:ManagedChat>, ``chatStateUpdates()``
  public func messageStream(
    bufferingPolicy: AsyncStream<ChatEvent>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<ChatEvent> {
    chat.messageStream(bufferingPolicy: bufferingPolicy)
  }

  /// Observes managed chat state transitions, starting immediately with the current snapshot.
  ///
  /// Slow consumers may skip intermediate snapshots and receive only the latest state.
  /// Calling this method never opens a network connection. The stream finishes when
  /// ``shutdownChat()`` is called.
  ///
  /// - Returns: An async stream yielding ``ChatState`` snapshots.
  /// - SeeAlso: <doc:ManagedChat>, ``chatState``
  public func chatStateUpdates() -> AsyncStream<ChatState> { chat.chatStateUpdates() }

  /// Records desired membership for a resolved channel and begins connecting without
  /// waiting for readiness.
  ///
  /// Because `channel` already contains both ID and login, no Helix lookup is performed—
  /// allowing anonymous IRC readers to join without OAuth credentials. Track readiness
  /// through ``chatStateUpdates()`` or call `join(to:)` to await readiness.
  ///
  /// - Parameter channel: A resolved ``ChatChannel`` containing the broadcaster's ID and login.
  /// - Throws: ``ChatError/invalidChannel``, ``ChatError/setupFailed(_:)``, ``ChatError/shutdown``,
  ///   or `CancellationError`.
  /// - SeeAlso: ``ChatChannel``, ``ChatChannelTarget``, <doc:ManagedChat>
  public func requestJoin(to channel: ChatChannel) throws { try chat.requestJoin(to: channel) }

  /// Resolves a channel target via Helix if not cached, records desired membership, and
  /// starts its reader without waiting for readiness.
  ///
  /// - Parameter target: An unresolved ``ChatChannelTarget`` identifying the broadcaster
  ///   by ID or login name.
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``ChatChannelTarget``, ``ChatChannel``, <doc:ManagedChat>
  public func requestJoin(to target: ChatChannelTarget) async throws {
    try await chat.requestJoin(.init(target))
  }

  /// Joins a resolved channel and suspends until its reader is ready.
  ///
  /// Because `channel` already contains both ID and login, no Helix lookup is performed.
  /// IRC readiness requires a matching channel ID in Twitch's `ROOMSTATE`.
  /// Cancelling the awaiting task cancels only the readiness wait and leaves the channel
  /// joined; call `part(from:)` to withdraw membership.
  ///
  /// - Parameter channel: A resolved ``ChatChannel`` containing the broadcaster's ID and login.
  /// - Throws: ``ChatError`` (such as ``ChatError/setupFailed(_:)``, ``ChatError/parted``,
  ///   or ``ChatError/credentialsChanged``) or `CancellationError`.
  /// - SeeAlso: ``ChatChannel``, ``ChatChannelTarget``, <doc:ManagedChat>
  public func join(to channel: ChatChannel) async throws { try await chat.join(to: channel) }

  /// Resolves a channel target via Helix if not cached, joins it, and suspends until ready.
  ///
  /// Cancelling the awaiting task preserves desired membership if resolution already
  /// succeeded; call `part(from:)` to leave the channel.
  ///
  /// - Parameter target: An unresolved ``ChatChannelTarget`` identifying the broadcaster
  ///   by ID or login name.
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``ChatChannelTarget``, ``ChatChannel``, <doc:ManagedChat>
  public func join(to target: ChatChannelTarget) async throws {
    try await chat.join(.init(target))
  }

  /// Leaves a resolved channel and withdraws any pending join for it.
  ///
  /// Emits ``ChatEvent/Payload/membershipEnded(_:)`` with ``ChatDeparture/Reason/requested``
  /// if the channel was joined.
  ///
  /// - Parameter channel: The ``ChatChannel`` to leave.
  public func part(from channel: ChatChannel) {
    chat.part(channelID: channel.id, login: channel.login)
  }

  /// Leaves a channel identified by ID or login name and withdraws any pending join for it.
  ///
  /// Parting by ``ChatChannelTarget/id(_:)`` completes locally without contacting Helix.
  /// Parting by ``ChatChannelTarget/login(_:)`` resolves the login via Helix if it is not
  /// already cached.
  ///
  /// - Parameter target: The ``ChatChannelTarget`` to leave.
  /// - Throws: ``ChatError`` or ``HelixError`` if an uncached login lookup fails.
  public func part(from target: ChatChannelTarget) async throws {
    switch target {
    case .id(let id): chat.part(channelID: id)
    case .login(let login): try await chat.part(.init(login: login))
    }
  }

  /// Overrides managed chat's sender privilege evidence for a specific channel.
  ///
  /// Supplying a ``ChatPrivilege`` overrides observed badges or `USERSTATE` evidence for
  /// local send pacing and opt-in ``ChatConfiguration/moderationEnrichment``. Pass `nil`
  /// to clear the override and fall back to observed evidence. Overrides are cleared when
  /// switching accounts or signing out. Calls while signed out leave privileges unchanged.
  ///
  /// - Parameters:
  ///   - privilege: The privilege override to install, or `nil` to restore observed evidence.
  ///   - channelID: The broadcaster's numeric Twitch user ID.
  /// - SeeAlso: <doc:ManagedChat>, ``ChatPrivilege``
  public func setChatPrivilege(_ privilege: ChatPrivilege?, in channelID: String) {
    chat.setChatPrivilege(privilege, in: channelID)
  }

  /// Permanently stops managed chat transports, clears memberships, and finishes all chat
  /// and raw IRC streams.
  ///
  /// After calling `shutdownChat()`, further managed chat join/send operations throw
  /// ``ChatError/shutdown``. Helix and direct EventSub APIs on this client remain usable.
  ///
  /// - SeeAlso: <doc:ManagedChat>, ``resetEventSub()``
  public func shutdownChat() async { await chat.shutdownChat().value }

  /// Sends a chat message to a resolved channel through the configured writer.
  ///
  /// Validates the message locally and applies process-local send admission from
  /// ``ChatConfiguration/sending`` (tracked per sender account across destinations).
  /// Ambiguous network writes are never retried automatically.
  ///
  /// - Important: When ``ChatConfiguration/writer`` is ``ChatConfiguration/Writer/irc``,
  ///   returning ``ChatSendOutcome/written(clientNonce:)`` means the command was written to
  ///   the socket—not that Twitch delivered it. Server rejections arrive separately as
  ///   ``ChatEvent/Payload/notice(code:message:)``.
  /// - Parameters:
  ///   - text: The message body (1–500 characters, free of CR/LF/NUL).
  ///   - channel: The resolved destination ``ChatChannel``.
  ///   - messageID: Optional parent message ID to reply to.
  ///   - clientNonce: Optional IRC `client-nonce` tag (IRC writer only; passing a value
  ///     with a Helix writer throws ``ChatSendError/unsupportedClientNonce``).
  ///   - maximumWait: Optional maximum time to wait if blocked solely by a per-channel
  ///     cooldown (``ChatSendEligibility/channelCooldown(until:)``). Account-window
  ///     exhaustion always refuses immediately.
  /// - Returns: A ``ChatSendOutcome`` describing acceptance or wire write status.
  /// - Throws: ``ChatSendError``, ``ChatError``, ``TwitchAuthenticationError``,
  ///   ``HelixError`` (for Helix writes), ``IRCError`` (for IRC writes), or
  ///   `CancellationError`.
  /// - SeeAlso: <doc:ManagedChat>, ``sendEligibility(in:)``, ``ChatSendingPolicy``
  @discardableResult
  public func sendMessage(
    _ text: String, in channel: ChatChannel, replyTo messageID: String? = nil,
    clientNonce: String? = nil, waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    try await chat.sendMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce,
      waitingForChannelCooldown: maximumWait)
  }

  /// Resolves a channel target via Helix if not cached and sends a chat message to it.
  ///
  /// - Parameters:
  ///   - text: The message body (1–500 characters, free of CR/LF/NUL).
  ///   - target: The destination ``ChatChannelTarget`` identifying the broadcaster by ID or
  ///     login name.
  ///   - messageID: Optional parent message ID to reply to.
  ///   - clientNonce: Optional IRC `client-nonce` tag (IRC writer only; passing a value
  ///     with a Helix writer throws ``ChatSendError/unsupportedClientNonce``).
  ///   - maximumWait: Optional maximum time to wait for a per-channel cooldown.
  /// - Returns: A ``ChatSendOutcome`` describing acceptance or wire write status.
  /// - Throws: ``ChatSendError``, ``ChatError``, ``TwitchAuthenticationError``,
  ///   ``HelixError``, ``IRCError``, or `CancellationError`.
  /// - SeeAlso: <doc:ManagedChat>, ``ChatChannelTarget``, ``sendEligibility(in:)``
  @discardableResult
  public func sendMessage(
    _ text: String, in target: ChatChannelTarget, replyTo messageID: String? = nil,
    clientNonce: String? = nil, waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    try Task.checkCancellation()
    guard !chat.isShutdown else { throw ChatError.shutdown }
    guard credentials?.user != nil else { throw TwitchAuthenticationError.userAccessTokenRequired }
    let channel = try await chat.resolveChatChannel(.init(target))
    return try await chat.sendMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce,
      waitingForChannelCooldown: maximumWait)
  }

  /// Returns the current account's process-local send eligibility in a channel.
  ///
  /// Accounts for the sender's recent managed send history across all channels, observed
  /// room slow mode, sender privileges, and any observed ban or timeout in `channelID`.
  /// Also begins tracking `channelID` in ``ChatState/sendEligibility``.
  ///
  /// - Parameter channelID: The broadcaster's numeric Twitch user ID.
  /// - Returns: The current ``ChatSendEligibility`` for `channelID`.
  /// - SeeAlso: <doc:ManagedChat>, ``ChatSendingPolicy``
  public func sendEligibility(in channelID: String) -> ChatSendEligibility {
    chat.sendEligibility(in: channelID)
  }
}

// Background work re-enters the same actor as public chat and credential operations.
extension TwitchClient {
  func withChat<Result: Sendable>(
    _ operation: @Sendable (ManagedChat) throws -> Result
  ) rethrows -> Result {
    try operation(chat)
  }
}
