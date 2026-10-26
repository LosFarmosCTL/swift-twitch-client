/// The membership state of a desired IRC channel.
public enum IRCChannelStatus: Sendable, Equatable {
  /// The desired channel is waiting for join confirmation.
  case joining
  /// The channel has been joined.
  case joined
  /// The connection is recovering and membership is being restored.
  case reconnecting
  /// The session or channel has failed; carries the failure reason.
  case failed(IRCChannelFailure)
}

/// The reason an IRC channel could not be joined or maintained.
public enum IRCChannelFailure: Sendable, Equatable {
  /// Twitch rejected the join; carries the server code and message.
  case joinRejected(code: String, message: String)
  /// The channel join did not complete before the deadline.
  case joinTimedOut
  /// Twitch rejected authentication for the session.
  case authenticationFailed
  /// The connection failed; carries a diagnostic description.
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
