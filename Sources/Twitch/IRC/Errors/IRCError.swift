/// An error thrown by IRC command validation, handshake, or raw send operations.
///
/// - SeeAlso: ``TwitchClient/sendIRC(_:)``, ``IRCState``, <doc:ManagedChat>
public enum IRCError: Error {
  /// A command parameter contains characters (such as CR, LF, or NUL) that cannot be
  /// safely serialized onto the IRC wire protocol.
  ///
  /// - Parameter parameter: The name of the invalid IRC field.
  case invalidInput(parameter: String)
  /// The IRC connection did not complete login and capability negotiation before the deadline.
  case handshakeTimedOut
  /// Twitch rejected the required `CAP REQ` capabilities during connection setup.
  case capabilitiesRejected
  /// Twitch rejected the IRC OAuth credentials (`Login authentication failed`).
  case loginFailed
  /// An internal IRC session was asked to start after already starting.
  case alreadyConnected
  /// The IRC transport is disconnected or has been shut down.
  case disconnected
  /// ``TwitchClient/sendIRC(_:)`` was called when ``ChatConfiguration/writer`` is not
  /// ``ChatConfiguration/Writer/irc``.
  case writerNotConfigured
}
