/// An input-validation, connection, or session-lifecycle error from Twitch IRC.
public enum IRCError: Error {
  /// Caller input cannot be safely represented in the given IRC field.
  case invalidInput(parameter: String)
  /// The connection did not complete its handshake before the deadline.
  case handshakeTimedOut
  /// Twitch rejected the required IRC capabilities.
  case capabilitiesRejected
  /// Twitch rejected the IRC login.
  case loginFailed
  /// The session has already started connecting.
  case alreadyConnected
  /// The session has been shut down.
  case disconnected
  /// Raw IRC sends require IRC to be configured as the chat writer.
  case writerNotConfigured
}
