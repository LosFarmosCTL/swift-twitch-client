import Foundation
import TwitchIRC

extension TwitchClient {
  /// Current membership, transport and sender state for the installed credentials.
  public var chatState: ChatState { chat.snapshot }

  /// Registers an independent observer without connecting. Explicit buffering policies
  /// bound memory and drop messages without slowing the reader.
  public func messageStream(
    bufferingPolicy: AsyncStream<ChatEvent>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<ChatEvent> {
    chat.messageStream(bufferingPolicy: bufferingPolicy)
  }

  /// Yields the current snapshot, then the latest state as it changes. Slow consumers
  /// may skip intermediate snapshots.
  public func chatStateUpdates() -> AsyncStream<ChatState> { chat.chatStateUpdates() }

  /// Records desired membership and starts its reader without waiting for readiness.
  public func requestJoin(to channel: ChatChannel) throws { try chat.requestJoin(to: channel) }

  public func requestJoin(channelID: String) async throws {
    try await chat.requestJoin(.id(channelID))
  }

  public func requestJoin(channelLogin: String) async throws {
    try await chat.requestJoin(.init(login: channelLogin))
  }

  /// Joins a channel and waits for readiness. Cancelling this wait preserves existing membership.
  public func join(to channel: ChatChannel) async throws { try await chat.join(to: channel) }

  public func join(channelID: String) async throws { try await chat.join(.id(channelID)) }

  public func join(channelLogin: String) async throws {
    try await chat.join(.init(login: channelLogin))
  }

  public func part(from channel: ChatChannel) {
    chat.part(channelID: channel.id, login: channel.login)
  }

  public func part(channelID: String) { chat.part(channelID: channelID) }

  public func part(channelLogin: String) async throws {
    try await chat.part(.init(login: channelLogin))
  }

  /// Supplies caller evidence for this sender and destination. Passing `nil` uses observed evidence.
  /// Overrides are scoped to the account.
  public func setChatPrivilege(_ privilege: ChatPrivilege?, in channelID: String) {
    chat.setChatPrivilege(privilege, in: channelID)
  }

  /// Permanently stops chat transports and observers. Helix and raw EventSub remain available.
  public func shutdownChat() async { await chat.shutdownChat().value }

  /// Sends through the configured writer. Process-local admission accounts for managed
  /// attempts by sender account. Ambiguous writes are never retried.
  /// `waitingForChannelCooldown` opts into a bounded wait for the destination. Account
  /// exhaustion refuses immediately.
  @discardableResult
  public func sendMessage(
    _ text: String, to channel: ChatChannel, replyTo messageID: String? = nil,
    clientNonce: String? = nil, waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    try await chat.sendMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce,
      waitingForChannelCooldown: maximumWait)
  }

  @discardableResult
  public func sendMessage(
    _ text: String, channelID: String, replyTo messageID: String? = nil,
    waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    let channel = try await chat.resolveChatChannel(.id(channelID))
    return try await chat.sendMessage(
      text, to: channel, replyTo: messageID, waitingForChannelCooldown: maximumWait)
  }

  @discardableResult
  public func sendMessage(
    _ text: String, channelLogin: String, replyTo messageID: String? = nil,
    waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    let channel = try await chat.resolveChatChannel(.init(login: channelLogin))
    return try await chat.sendMessage(
      text, to: channel, replyTo: messageID, waitingForChannelCooldown: maximumWait)
  }

  /// Current local eligibility, including the account's history across destinations.
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
