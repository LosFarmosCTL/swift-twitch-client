public enum IRCError: Error {
  case loginFailed
  case alreadyConnected
  case disconnected
  case writeConnectionNotEnabled
}
