import Foundation
import TwitchIRC

/// A raw parsed IRC message from one of the client's configured transports.
public struct IRCMessage: Sendable {
  public let role: IRCRecovery.Role
  public let message: IncomingMessage
}

/// Callback deliveries from the unified client's raw IRC stream.
public enum IRCListenerEvent: Sendable {
  case message(IRCMessage)
  case finished
}

extension TwitchClient {
  /// Observes parsed IRC traffic without starting a connection. The stream survives transport
  /// recovery and finishes on chat shutdown. Explicit buffering policies bound pending events.
  public func ircMessageStream(
    bufferingPolicy: AsyncStream<IRCMessage>.Continuation.BufferingPolicy = .unbounded
  ) -> AsyncStream<IRCMessage> {
    chat.ircMessageStream(bufferingPolicy: bufferingPolicy)
  }

  /// Writes a validated command to the IRC writer without managed chat admission.
  public func sendIRC(_ message: OutgoingMessage) async throws {
    try await chat.sendIRC(message)
  }

  /// Convenience wrapper over `ircMessageStream()`. Explicit cancellation removes
  /// this observer only; transport failures remain visible in `chatState`.
  /// The callback has no actor or main-thread guarantee.
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
    /// Each subscriber synchronously registers its own observer on subscription.
    /// Creating a publisher registers nothing. Cancellation removes only that subscriber,
    /// never membership or the connection. Values are not buffered without demand.
    /// Shutdown (including a late subscription) completes normally; transport failures
    /// remain in `chatState` and do not terminate observers.
    public nonisolated func ircMessagePublisher() -> AnyPublisher<IRCMessage, Never> {
      ircPublishers.publisher()
    }
  }
#endif
