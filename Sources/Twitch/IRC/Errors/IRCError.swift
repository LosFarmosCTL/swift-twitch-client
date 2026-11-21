import Foundation

/// An error thrown by IRC command validation, handshake, or raw send operations.
///
/// - SeeAlso: ``TwitchClient/sendIRC(_:)``, ``IRCState``, <doc:ManagedChat>
public enum IRCError: Error, Sendable, Equatable, Hashable {
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
  /// The IRC transport is disconnected or has been shut down.
  case disconnected
  /// ``TwitchClient/sendIRC(_:)`` was called when ``ChatConfiguration/writer`` is not
  /// ``ChatConfiguration/Writer/irc``.
  case writerNotConfigured
}

internal enum IRCInternalError: Error, Sendable {
  case alreadyConnected
}

extension IRCError: CustomStringConvertible {
  /// A diagnostic description of the IRC error.
  public var description: String {
    switch self {
    case .invalidInput(let parameter):
      "Invalid IRC input for \(parameter)."
    case .handshakeTimedOut:
      "IRC handshake timed out."
    case .capabilitiesRejected:
      "Twitch rejected the requested IRC capabilities."
    case .loginFailed:
      "IRC login authentication failed."
    case .disconnected:
      "IRC connection disconnected."
    case .writerNotConfigured:
      "An IRC chat writer is not configured."
    }
  }
}

#if !os(Linux)
  extension IRCError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      switch self {
      case .invalidInput(let parameter):
        .init("Invalid IRC input for \(parameter).", bundle: .twitchModule)
      case .handshakeTimedOut:
        .init("IRC handshake timed out.", bundle: .twitchModule)
      case .capabilitiesRejected:
        .init("Twitch rejected the requested IRC capabilities.", bundle: .twitchModule)
      case .loginFailed:
        .init("IRC login authentication failed.", bundle: .twitchModule)
      case .disconnected:
        .init("IRC connection disconnected.", bundle: .twitchModule)
      case .writerNotConfigured:
        .init("An IRC chat writer is not configured.", bundle: .twitchModule)
      }
    }
  }
#endif

extension IRCError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
