import Foundation

/// An error thrown by managed chat membership, resolution, or lifecycle operations.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendError``
public enum ChatError: Error, Sendable, Equatable {
  /// The supplied channel ID or login is empty or contains invalid characters.
  case invalidChannel
  /// Helix returned no Twitch user matching the requested channel ID or login.
  case channelNotFound
  /// The channel was parted before a pending join or lookup completed.
  case parted
  /// Credentials changed on the client while a join or lookup was waiting to finish.
  case credentialsChanged
  /// Setting up the channel's reader transport or EventSub topics failed.
  case setupFailed(String)
  /// Managed chat has been permanently shut down via ``TwitchClient/shutdownChat()``.
  case shutdown
}

extension ChatError: CustomStringConvertible {
  /// A diagnostic description of the managed chat error.
  public var description: String {
    switch self {
    case .invalidChannel:
      "Invalid chat channel."
    case .channelNotFound:
      "Chat channel not found."
    case .parted:
      "Chat channel was parted."
    case .credentialsChanged:
      "Client credentials changed."
    case .setupFailed(let reason):
      "Chat setup failed: \(reason)"
    case .shutdown:
      "Managed chat has been shut down."
    }
  }
}

#if !os(Linux)
  extension ChatError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      switch self {
      case .invalidChannel:
        .init("Invalid chat channel.", bundle: .twitchModule)
      case .channelNotFound:
        .init("Chat channel not found.", bundle: .twitchModule)
      case .parted:
        .init("Chat channel was parted.", bundle: .twitchModule)
      case .credentialsChanged:
        .init("Client credentials changed.", bundle: .twitchModule)
      case .setupFailed(let reason):
        .init("Chat setup failed: \(reason)", bundle: .twitchModule)
      case .shutdown:
        .init("Managed chat has been shut down.", bundle: .twitchModule)
      }
    }
  }
#endif

extension ChatError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}

/// A validation, local-admission, or delivery error thrown by managed chat sends.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendOutcome``, ``ChatSendEligibility``
public enum ChatSendError: Error, Sendable, Equatable {
  /// The message text is empty, exceeds 500 characters, contains unsafe wire characters,
  /// or `replyTo` / `clientNonce` is empty or contains NUL bytes.
  case invalidMessage
  /// Local send admission refused the attempt; carries the blocking ``ChatSendEligibility``.
  case refused(ChatSendEligibility)
  /// Helix returned `isSent == false` with a Twitch drop code and explanation.
  case rejected(code: String?, message: String)
  /// A `clientNonce` was supplied when ``ChatConfiguration/writer`` is
  /// ``ChatConfiguration/Writer/helix`` (client nonces are supported only by IRC writers).
  case unsupportedClientNonce
}

extension ChatSendError: CustomStringConvertible {
  /// A diagnostic description of the managed chat send error.
  public var description: String {
    switch self {
    case .invalidMessage:
      "Invalid chat message."
    case .refused(.channelCooldown):
      "Chat message refused: channel cooldown active."
    case .refused(.accountWindow):
      "Chat message refused: account send rate limit reached."
    case .refused(.banned):
      "Chat message refused: account is banned in this channel."
    case .refused(.timedOut):
      "Chat message refused: account is timed out in this channel."
    case .refused(.unavailable(let reason)):
      "Chat message refused: \(reason)"
    case .refused(.eligible):
      "Chat message refused."
    case .rejected(let code?, let message):
      "Chat message rejected (\(code)): \(message)"
    case .rejected(nil, let message):
      "Chat message rejected: \(message)"
    case .unsupportedClientNonce:
      "Client nonces are only supported when sending over IRC."
    }
  }
}

#if !os(Linux)
  extension ChatSendError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      switch self {
      case .invalidMessage:
        .init("Invalid chat message.", bundle: .twitchModule)
      case .refused(.channelCooldown):
        .init("Chat message refused: channel cooldown active.", bundle: .twitchModule)
      case .refused(.accountWindow):
        .init("Chat message refused: account send rate limit reached.", bundle: .twitchModule)
      case .refused(.banned):
        .init("Chat message refused: account is banned in this channel.", bundle: .twitchModule)
      case .refused(.timedOut):
        .init(
          "Chat message refused: account is timed out in this channel.", bundle: .twitchModule)
      case .refused(.unavailable(let reason)):
        .init("Chat message refused: \(reason)", bundle: .twitchModule)
      case .refused(.eligible):
        .init("Chat message refused.", bundle: .twitchModule)
      case .rejected(let code?, let message):
        .init("Chat message rejected (\(code)): \(message)", bundle: .twitchModule)
      case .rejected(nil, let message):
        .init("Chat message rejected: \(message)", bundle: .twitchModule)
      case .unsupportedClientNonce:
        .init("Client nonces are only supported when sending over IRC.", bundle: .twitchModule)
      }
    }
  }
#endif

extension ChatSendError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
