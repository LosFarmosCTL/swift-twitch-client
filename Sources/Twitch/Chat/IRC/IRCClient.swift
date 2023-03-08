internal class IRCClient {
  internal weak var delegate: IRCClientDelegate?

  internal func connect() {}
  internal func disconnect() {}
  internal func send(_ message: String) {}
}

internal protocol IRCClientDelegate: AnyObject {
  func didReceiveMessage(_ message: IRCMessage)
}
