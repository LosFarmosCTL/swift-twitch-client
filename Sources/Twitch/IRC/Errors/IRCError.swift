/// A connection or session-lifecycle error from Twitch IRC.
public enum IRCError: Error {
  /// The connection did not complete its handshake before the deadline.
  case handshakeTimedOut
  /// Twitch rejected the IRC login.
  case loginFailed
  /// The session has already started connecting.
  case alreadyConnected
  /// The session has been shut down.
  case disconnected
  /// The session was created without a write connection.
  case writeConnectionNotEnabled
}
