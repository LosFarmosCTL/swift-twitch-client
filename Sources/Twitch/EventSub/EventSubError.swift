import Foundation

/// A terminal EventSub subscription revocation or WebSocket connection failure.
///
/// Delivered as a thrown error from ``TwitchClient/eventStream(for:bufferingPolicy:)``,
/// via ``EventSubListenerEvent/failure(_:)`` in ``TwitchClient/eventListener(for:callback:)``,
/// or as a Combine failure in ``TwitchClient/eventPublisher(for:)``.
///
/// - SeeAlso: <doc:EventSub>, ``EventSubRevocation``
public enum EventSubError: Error, Sendable {
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

extension EventSubError: CustomStringConvertible {
  /// A diagnostic description of the EventSub error.
  public var description: String {
    switch self {
    case .revocation(let revocation):
      "EventSub subscription revoked: \(revocation.status.rawValue)"
    case .disconnected(let error):
      "EventSub disconnected: \(error.localizedDescription)"
    case .timedOut:
      "EventSub timed out."
    }
  }
}

#if !os(Linux)
  extension EventSubError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      switch self {
      case .revocation(let revocation):
        .init(
          "EventSub subscription revoked: \(revocation.status.rawValue)",
          bundle: .twitchModule)
      case .disconnected(let error):
        .init("EventSub disconnected: \(error.localizedDescription)", bundle: .twitchModule)
      case .timedOut:
        .init("EventSub timed out.", bundle: .twitchModule)
      }
    }
  }
#endif

extension EventSubError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
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
