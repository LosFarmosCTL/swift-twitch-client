import Foundation
import TwitchIRC

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
  /// through ``chatStateUpdates()`` or call ``join(to:)`` to await readiness.
  ///
  /// - Parameter channel: A resolved ``ChatChannel`` containing the broadcaster's ID and login.
  /// - Throws: ``ChatError/invalidChannel``, ``ChatError/shutdown``, or `CancellationError`.
  /// - SeeAlso: ``join(to:)``, ``part(from:)``
  public func requestJoin(to channel: ChatChannel) throws { try chat.requestJoin(to: channel) }

  /// Resolves a channel by Twitch user ID via Helix, records desired membership, and starts
  /// its reader without waiting for readiness.
  ///
  /// - Parameter id: The broadcaster's numeric Twitch user ID.
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``join(id:)``, ``requestJoin(to:)``
  public func requestJoin(id: String) async throws {
    try await chat.requestJoin(.id(id))
  }

  /// Resolves a channel by login name via Helix, records desired membership, and starts its
  /// reader without waiting for readiness.
  ///
  /// - Parameter login: The broadcaster's login name (with or without a leading `#`).
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``join(login:)``, ``requestJoin(to:)``
  public func requestJoin(login: String) async throws {
    try await chat.requestJoin(.init(login: login))
  }

  /// Joins a resolved channel and suspends until its reader is ready.
  ///
  /// Because `channel` already contains both ID and login, no Helix lookup is performed.
  /// Cancelling the awaiting task cancels only the readiness wait and leaves the channel
  /// joined; call ``part(from:)`` to withdraw membership.
  ///
  /// - Parameter channel: A resolved ``ChatChannel`` containing the broadcaster's ID and login.
  /// - Throws: ``ChatError`` (such as ``ChatError/setupFailed(_:)``, ``ChatError/parted``,
  ///   or ``ChatError/credentialsChanged``) or `CancellationError`.
  /// - SeeAlso: <doc:ManagedChat>, ``requestJoin(to:)``, ``part(from:)``
  public func join(to channel: ChatChannel) async throws { try await chat.join(to: channel) }

  /// Resolves a channel by Twitch user ID via Helix, joins it, and suspends until ready.
  ///
  /// Cancelling the awaiting task preserves desired membership if resolution already
  /// succeeded; call ``part(id:)`` to leave the channel.
  ///
  /// - Parameter id: The broadcaster's numeric Twitch user ID.
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``join(to:)``, ``part(id:)``
  public func join(id: String) async throws { try await chat.join(.id(id)) }

  /// Resolves a channel by login name via Helix, joins it, and suspends until ready.
  ///
  /// Cancelling the awaiting task preserves desired membership if resolution already
  /// succeeded; call ``part(login:)`` to leave the channel.
  ///
  /// - Parameter login: The broadcaster's login name (with or without a leading `#`).
  /// - Throws: ``ChatError``, ``HelixError`` if resolution fails, or `CancellationError`.
  /// - SeeAlso: ``join(to:)``, ``part(login:)``
  public func join(login: String) async throws {
    try await chat.join(.init(login: login))
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

  /// Leaves a channel by Twitch user ID and withdraws any pending join for it.
  ///
  /// - Parameter id: The broadcaster's numeric Twitch user ID.
  public func part(id: String) { chat.part(channelID: id) }

  /// Resolves a channel login if not already cached, then leaves the channel.
  ///
  /// - Parameter login: The broadcaster's login name (with or without a leading `#`).
  /// - Throws: ``ChatError`` or ``HelixError`` if the login is uncached and lookup fails.
  public func part(login: String) async throws {
    try await chat.part(.init(login: login))
  }

  /// Overrides managed chat's sender privilege evidence for a specific channel.
  ///
  /// Supplying a ``ChatPrivilege`` overrides observed badges or `USERSTATE` evidence for
  /// local send pacing and opt-in ``ChatConfiguration/moderationEnrichment``. Pass `nil`
  /// to clear the override and fall back to observed evidence. Overrides are cleared on
  /// credential switches.
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
    _ text: String, to channel: ChatChannel, replyTo messageID: String? = nil,
    clientNonce: String? = nil, waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    try await chat.sendMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce,
      waitingForChannelCooldown: maximumWait)
  }

  /// Resolves a channel by Twitch user ID via Helix and sends a chat message to it.
  ///
  /// - Parameters:
  ///   - text: The message body (1–500 characters, free of CR/LF/NUL).
  ///   - id: The destination broadcaster's numeric Twitch user ID.
  ///   - messageID: Optional parent message ID to reply to.
  ///   - maximumWait: Optional maximum time to wait for a per-channel cooldown.
  /// - Returns: A ``ChatSendOutcome`` describing acceptance or wire write status.
  /// - Throws: ``ChatSendError``, ``ChatError``, ``TwitchAuthenticationError``,
  ///   ``HelixError``, ``IRCError``, or `CancellationError`.
  /// - SeeAlso: ``sendMessage(_:to:replyTo:clientNonce:waitingForChannelCooldown:)``
  @discardableResult
  public func sendMessage(
    _ text: String, id: String, replyTo messageID: String? = nil,
    waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    let channel = try await chat.resolveChatChannel(.id(id))
    return try await chat.sendMessage(
      text, to: channel, replyTo: messageID, waitingForChannelCooldown: maximumWait)
  }

  /// Resolves a channel by login name via Helix and sends a chat message to it.
  ///
  /// - Parameters:
  ///   - text: The message body (1–500 characters, free of CR/LF/NUL).
  ///   - login: The destination broadcaster's login name (with or without `#`).
  ///   - messageID: Optional parent message ID to reply to.
  ///   - maximumWait: Optional maximum time to wait for a per-channel cooldown.
  /// - Returns: A ``ChatSendOutcome`` describing acceptance or wire write status.
  /// - Throws: ``ChatSendError``, ``ChatError``, ``TwitchAuthenticationError``,
  ///   ``HelixError``, ``IRCError``, or `CancellationError`.
  /// - SeeAlso: ``sendMessage(_:to:replyTo:clientNonce:waitingForChannelCooldown:)``
  @discardableResult
  public func sendMessage(
    _ text: String, login: String, replyTo messageID: String? = nil,
    waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    let channel = try await chat.resolveChatChannel(.init(login: login))
    return try await chat.sendMessage(
      text, to: channel, replyTo: messageID, waitingForChannelCooldown: maximumWait)
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
