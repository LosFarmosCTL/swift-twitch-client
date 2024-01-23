import Foundation

internal enum WebSocketError: Error {
  case disconnected
  case alreadyConnected
  case invalidMessageReceived(data: Data?)
}
