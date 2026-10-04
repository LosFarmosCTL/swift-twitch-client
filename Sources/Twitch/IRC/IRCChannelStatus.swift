public enum IRCChannelStatus: Sendable, Equatable {
  case joining
  case joined
  case reconnecting
  case failed(IRCChannelFailure)
}

public enum IRCChannelFailure: Sendable, Equatable {
  case joinRejected(code: String, message: String)
  case joinTimedOut
  case authenticationFailed
  case connectionFailed(String)

  internal init(terminalError: Error) {
    switch terminalError {
    case IRCError.loginFailed:
      self = .authenticationFailed
    default:
      self = .connectionFailed(String(describing: terminalError))
    }
  }
}
