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
