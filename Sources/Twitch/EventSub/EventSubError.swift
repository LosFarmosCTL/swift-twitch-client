import Foundation

public enum EventSubError: Error {
  case revocation(EventSubRevocation)
  case disconnected(with: Error)
  case timedOut
}

internal enum EventSubConnectionError: Error {
  case revocation(EventSubRevocation)
  case reconnectRequested(reconnectURL: URL, socketID: String)
  case timedOut(socketID: String)
  case disconnected(with: Error, socketID: String)
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
