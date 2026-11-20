/// Fixed transports and optional behavior for managed chat. Raw APIs are unaffected.
public struct ChatConfiguration: Sendable {
  public enum IRCAuthentication: Sendable, Equatable {
    case anonymous
    case authenticated
  }

  public enum Reader: Sendable, Equatable {
    case irc(IRCAuthentication)
    case eventSub
  }

  public enum Writer: Sendable, Equatable {
    case helix
    case irc
  }

  public let reader: Reader
  public let writer: Writer
  public let sending: ChatSendingPolicy
  /// Enables optional moderation details when role evidence and granted scopes allow it.
  public let moderationEnrichment: Bool
  /// Optionally discovers moderator roles using Get Moderated Channels.
  public let prefillModeratedChannels: Bool

  public init(
    reader: Reader = .irc(.authenticated),
    writer: Writer = .helix,
    sending: ChatSendingPolicy = .interactive,
    moderationEnrichment: Bool = false,
    prefillModeratedChannels: Bool = false
  ) {
    self.reader = reader
    self.writer = writer
    self.sending = sending
    self.moderationEnrichment = moderationEnrichment
    self.prefillModeratedChannels = prefillModeratedChannels
  }
}

/// What happens to managed membership when credentials are replaced.
public enum ChatCredentialSwitchBehavior: Sendable, Equatable {
  /// Retains desired channels. Anonymous IRC stays connected; account-bound readers
  /// restart with the new credentials. Old readiness waits end with credentialsChanged.
  case preserveChannels
  /// Parts managed channels and ends their readiness waits.
  case partChannels
}

/// Interactive admission, not an outgoing-message scheduler or a delivery guarantee.
public struct ChatSendingPolicy: Sendable, Equatable {
  /// No automatic waiting. Account-window exhaustion always refuses immediately.
  public static let interactive = Self()
  /// Bypasses local pacing/admission, but still records managed attempts. Validation
  /// and observed restrictions still apply.
  public static let unpaced = Self(enforcesLimits: false)

  public let enforcesLimits: Bool
  /// Ordinary destinations need more than one second between managed sends.
  public let ordinaryChannelInterval: Duration

  public init(
    enforcesLimits: Bool = true,
    ordinaryChannelInterval: Duration = .milliseconds(1100)
  ) {
    self.enforcesLimits = enforcesLimits
    self.ordinaryChannelInterval = max(.milliseconds(1001), ordinaryChannelInterval)
  }
}
