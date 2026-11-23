/// The join and recovery status of a single channel on an IRC read transport.
///
/// Reported per channel login in ``IRCState/channels``.
///
/// - SeeAlso: ``IRCChannelFailure``, ``IRCState``
public enum IRCChannelStatus: Sendable, Equatable {
  /// A `JOIN` command has been queued or sent and is awaiting Twitch's confirmation.
  case joining
  /// Twitch confirmed channel membership and messages are being received.
  case joined
  /// The underlying IRC connection is recovering and will rejoin this channel automatically.
  case reconnecting
  /// Joining or maintaining this channel failed; carries the ``IRCChannelFailure`` reason.
  case failed(IRCChannelFailure)

  internal var isFailed: Bool {
    if case .failed = self { true } else { false }
  }
}

/// The reason an IRC channel join or transport session failed.
///
/// - SeeAlso: ``IRCChannelStatus``, ``IRCState/Status``
public enum IRCChannelFailure: Sendable, Equatable {
  /// Twitch rejected the `JOIN` with a server notice (for example, a suspended channel).
  ///
  /// - Parameters:
  ///   - code: The Twitch `msg-id` notice code.
  ///   - message: The human-readable notice text from Twitch.
  case joinRejected(code: String, message: String)
  /// Twitch did not confirm the `JOIN` before the timeout deadline elapsed.
  case joinTimedOut
  /// Twitch rejected the IRC OAuth login credentials.
  case authenticationFailed
  /// The IRC transport failed with an unrecoverable connection error.
  case connectionFailed(String)

  internal init(terminalError: Error) {
    switch terminalError {
    case IRCError.loginFailed, is TwitchAuthenticationError:
      self = .authenticationFailed
    default:
      self = .connectionFailed(String(describing: terminalError))
    }
  }
}
