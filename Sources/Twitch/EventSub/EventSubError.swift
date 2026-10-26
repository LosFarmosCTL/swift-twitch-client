import Foundation

/// A subscription revocation or EventSub connection failure.
public enum EventSubError: Error {
  /// Twitch revoked a subscription; carries the revocation payload.
  case revocation(EventSubRevocation)
  /// The EventSub connection ended; carries the underlying error.
  case disconnected(with: Error)
  /// The EventSub connection timed out.
  case timedOut
}

internal enum EventSubConnectionError: Error {
  case revocation(EventSubRevocation)
  case reconnectRequested(reconnectURL: URL, sessionID: String)
  case timedOut(sessionID: String)
  case disconnected(with: Error, sessionID: String)
}

extension EventSubConnectionError {
  var eventSubError: EventSubError {
    switch self {
    case .revocation(let revocation):
      return .revocation(revocation)
    case .timedOut:
      return .timedOut
    case .disconnected(let error, _):
      return .disconnected(with: error)
    case .reconnectRequested:
      return .disconnected(with: self)
    }
  }
}
