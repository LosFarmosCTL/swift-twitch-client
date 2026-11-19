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
