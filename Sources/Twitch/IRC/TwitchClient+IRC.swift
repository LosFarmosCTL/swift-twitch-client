import Foundation
public import TwitchIRC

/// A parsed Twitch IRC frame paired with the transport role that received it.
///
/// Emitted by ``TwitchClient/ircMessageStream(bufferingPolicy:)``,
/// ``TwitchClient/ircMessageListener(_:)``, and ``TwitchClient/ircMessagePublisher()``.
///
/// - SeeAlso: <doc:ManagedChat>, ``IRCRecovery/Role``
public struct IRCMessage: Sendable {
  /// Whether the frame arrived on the IRC read pool or the dedicated IRC write connection.
  public let role: IRCRecovery.Role
  /// The parsed `TwitchIRC` incoming message.
  public let message: IncomingMessage

  /// Creates an `IRCMessage` value.
  public init(
    role: IRCRecovery.Role,
    message: IncomingMessage
  ) {
    self.role = role
    self.message = message
  }
}

/// A delivery sent to a callback registered with ``TwitchClient/ircMessageListener(_:)``.
///
/// - SeeAlso: ``IRCMessage``, <doc:ManagedChat>
public enum IRCListenerEvent: Sendable {
  /// A parsed IRC frame from one of the client's configured IRC transports.
  case message(IRCMessage)
  /// Managed chat shut down and no further IRC frames will arrive.
  case finished
}

extension TwitchClient {
  /// Observes raw parsed IRC traffic from the client's configured IRC transports.
  ///
  /// Registering a stream does not open any connection; traffic flows once managed chat
  /// connects an IRC reader or writer (see ``ChatConfiguration``). The stream survives
  /// automatic connection recovery and credential switches, and finishes when
  /// ``shutdownChat()`` is called.
  ///
  /// - Parameter bufferingPolicy: How to buffer unread IRC frames. Defaults to `.unbounded`.
  ///   Explicit bounded policies cap memory without slowing the IRC reader.
  /// - Returns: An independent async stream of ``IRCMessage`` values.
  /// - SeeAlso: <doc:ManagedChat>, ``ircMessageListener(_:)``, ``ircMessagePublisher()``,
  ///   ``sendIRC(_:)``
  public func ircMessageStream(
    bufferingPolicy: AsyncStream<IRCMessage>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<IRCMessage> {
    chat.ircMessageStream(bufferingPolicy: bufferingPolicy)
  }

  /// Sends a raw IRC command over the client's configured IRC write connection.
  ///
  /// Raw sends validate wire safety (rejecting CR/LF or null-byte injection) and require
  /// ``ChatConfiguration/writer`` to be ``ChatConfiguration/Writer/irc``, but bypass
  /// managed chat's local send pacing and eligibility checks.
  ///
  /// - Parameter message: The `TwitchIRC` outgoing command to serialize and send.
  /// - Throws: ``IRCError/writerNotConfigured`` if the client is not configured with an IRC
  ///   writer, ``IRCError/invalidInput(parameter:)`` if the command fails wire validation,
  ///   ``TwitchAuthenticationError/userAccessTokenRequired`` without user credentials,
  ///   ``ChatError/shutdown`` after chat shutdown, or a transport ``IRCError``.
  /// - SeeAlso: <doc:ManagedChat>,
  ///   ``TwitchClient/sendMessage(_:in:replyTo:clientNonce:waitingForChannelCooldown:)-(_,ChatChannel,_,_,_)``
  public func sendIRC(_ message: OutgoingMessage) async throws {
    try await chat.sendIRC(message)
  }

  /// Registers a callback observer for raw parsed IRC traffic.
  ///
  /// Built on top of ``ircMessageStream(bufferingPolicy:)``. Calling
  /// ``TwitchCancellable/cancel()`` on the returned handle removes only this observer and
  /// leaves chat membership and connections intact. Transport failures are surfaced in
  /// ``chatState`` rather than terminating the callback.
  ///
  /// - Parameter callback: A closure invoked with ``IRCListenerEvent`` deliveries. Has no
  ///   main-actor guarantee.
  /// - Returns: A ``TwitchCancellable`` handle that stops delivery to this callback.
  /// - SeeAlso: <doc:ManagedChat>, ``ircMessageStream(bufferingPolicy:)``
  public func ircMessageListener(
    _ callback: @escaping @Sendable (IRCListenerEvent) -> Void
  ) -> TwitchCancellable {
    let stream = ircMessageStream()
    let task = Task {
      for await message in stream { callback(.message(message)) }
      if !Task.isCancelled { callback(.finished) }
    }

    return TwitchCancellable { task.cancel() }
  }
}

#if canImport(Combine)
  @preconcurrency import Combine

  extension TwitchClient {
    /// Creates a lazy Combine publisher of raw parsed IRC traffic.
    ///
    /// Creating the publisher does not register an observer or open a connection. Each
    /// downstream subscriber registers independently upon subscription, and cancelling a
    /// subscriber removes only that registration without affecting chat membership or
    /// connections. Frames arriving without downstream demand are dropped rather than
    /// buffered.
    ///
    /// The publisher completes normally after ``shutdownChat()`` (including for late
    /// subscribers). Transport failures appear in ``chatState`` and do not fail the
    /// publisher.
    ///
    /// - Returns: A publisher emitting ``IRCMessage`` values and never failing.
    /// - SeeAlso: <doc:ManagedChat>, ``ircMessageStream(bufferingPolicy:)``
    public nonisolated func ircMessagePublisher() -> AnyPublisher<IRCMessage, Never> {
      ircPublishers.publisher()
    }
  }
#endif
