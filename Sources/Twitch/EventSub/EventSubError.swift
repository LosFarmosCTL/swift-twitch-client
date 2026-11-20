import Foundation

/// A terminal EventSub subscription revocation or WebSocket connection failure.
///
/// Delivered as a thrown error from ``TwitchClient/eventStream(for:bufferingPolicy:)``,
/// via ``EventSubListenerEvent/failure(_:)`` in ``TwitchClient/eventListener(for:callback:)``,
/// or as a Combine failure in ``TwitchClient/eventPublisher(for:)``.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubRevocation``
public enum EventSubError: Error {
  /// Twitch revoked the subscription (for example, authorization was revoked or a chat
  /// user was banned or timed out).
  case revocation(EventSubRevocation)
  /// The EventSub WebSocket disconnected unexpectedly or failed during a reconnect handoff.
  ///
  /// - Parameter with: The underlying transport or session error.
  case disconnected(with: Error)
  /// The EventSub WebSocket failed to complete its welcome handshake, keepalive check, or
  /// reconnect handoff within Twitch's deadline.
  case timedOut
}

extension EventSubError {
  static func normalizeSetupError(_ error: Error) -> Error {
    if error is CancellationError { return CancellationError() }

    guard let error = error as? EventSubError else {
      return EventSubError.disconnected(with: error)
    }

    if case .disconnected(let underlying) = error, underlying is CancellationError {
      return CancellationError()
    }

    return error
  }
}
