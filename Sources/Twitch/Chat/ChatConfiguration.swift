/// Transport and behavior configuration for managed chat on a ``TwitchClient``.
///
/// Pass a `ChatConfiguration` to ``TwitchClient/init(credentials:chat:urlSession:diagnostics:)``
/// to choose how managed chat reads events, sends messages, enforces local send pacing,
/// and enables optional moderation features. Configuration is fixed for the lifetime of a
/// client and does not restrict direct Helix or EventSub APIs.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendingPolicy``, ``ChatCredentialSwitchBehavior``
public struct ChatConfiguration: Sendable {
  /// Whether an IRC chat reader connects anonymously or using the client's user credentials.
  public enum IRCAuthentication: Sendable, Equatable {
    /// Connect to Twitch IRC as an anonymous `justinfan` reader without OAuth credentials.
    ///
    /// Joining a pre-resolved ``ChatChannel`` requires no Helix lookup or OAuth token.
    /// Joining by login or user ID resolves the channel through Helix and still requires
    /// valid credentials. Anonymous readers stay connected across
    /// ``TwitchClient/switchCredentials(to:chatBehavior:)`` when channels are preserved.
    case anonymous
    /// Authenticate the IRC reader with the client's user OAuth token (`chat:read`).
    case authenticated
  }

  /// The transport managed chat uses to receive channel events.
  public enum Reader: Sendable, Equatable {
    /// Receive chat over Twitch IRC WebSockets (either authenticated or anonymous).
    case irc(IRCAuthentication)
    /// Receive chat over EventSub WebSockets (`user:read:chat` user token required).
    ///
    /// Subscribes per joined channel to chat message, notification, deletion, clear, and
    /// settings-update topics and fetches an initial room-settings snapshot via Helix.
    case eventSub
  }

  /// The transport managed chat uses to send outgoing messages.
  public enum Writer: Sendable, Equatable {
    /// Send messages via Helix `Send Chat Message` (`user:write:chat` required).
    ///
    /// Returns ``ChatSendOutcome/accepted(messageID:)`` when Twitch accepts delivery or
    /// throws ``ChatSendError/rejected(code:message:)`` if Twitch drops the message.
    case helix
    /// Send messages over a dedicated authenticated IRC write connection (`chat:edit` required).
    ///
    /// Returns ``ChatSendOutcome/written(clientNonce:)`` once written to the wire; later
    /// server rejections arrive asynchronously as ``ChatEvent/Payload/notice(code:message:)``.
    case irc
  }

  /// The transport used to receive chat events for joined channels.
  public let reader: Reader
  /// The transport used to send outgoing chat messages.
  public let writer: Writer
  /// Process-local pacing and rate-limit admission policy applied to managed sends.
  public let sending: ChatSendingPolicy
  /// Whether managed chat subscribes to `channel.moderate` v2 EventSub notifications for
  /// channels where the account is known to be a moderator or broadcaster.
  ///
  /// Enrichment activates only when both role evidence (observed or supplied via
  /// ``TwitchClient/setChatPrivilege(_:in:)``) and positively known moderation scopes on
  /// ``TwitchCredentials/scopes`` are present. Moderation events are added alongside
  /// reader events without replacing them.
  public let moderationEnrichment: Bool
  /// Whether managed chat calls `Get Moderated Channels` once per credential revision to
  /// discover channels where the user is a moderator.
  ///
  /// Runs only when `user:read:moderated_channels` is positively present in
  /// ``TwitchCredentials/scopes``. Discovered roles improve send pacing and can activate
  /// ``moderationEnrichment`` before observing a message in a channel, but never override
  /// newer direct role observations.
  public let prefillModeratedChannels: Bool

  /// Creates a managed chat configuration.
  ///
  /// - Parameters:
  ///   - reader: The transport for reading chat. Defaults to `.irc(.authenticated)`.
  ///   - writer: The transport for sending chat. Defaults to `.helix`.
  ///   - sending: Local send pacing policy. Defaults to ``ChatSendingPolicy/interactive``.
  ///   - moderationEnrichment: Whether to enable opt-in EventSub moderation enrichment.
  ///     Defaults to `false`.
  ///   - prefillModeratedChannels: Whether to discover moderated channels via Helix.
  ///     Defaults to `false`.
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

/// How managed chat handles existing channel memberships during
/// ``TwitchClient/switchCredentials(to:chatBehavior:)``.
///
/// - SeeAlso: <doc:ManagedChat>, <doc:Authentication>, ``ChatCredentialChange``
public enum ChatCredentialSwitchBehavior: Sendable, Equatable {
  /// Retains all desired channels across the credential switch.
  ///
  /// An anonymous IRC reader remains connected, while account-bound readers and writers
  /// restart with the new credentials. In-flight readiness waits from before the switch
  /// fail with ``ChatError/credentialsChanged``.
  case preserveChannels
  /// Parts all managed channels and fails any pending readiness waits with
  /// ``ChatError/credentialsChanged``.
  case partChannels
}

/// Process-local send pacing applied to managed chat sends.
///
/// `ChatSendingPolicy` enforces local admission checks (20 messages per 30 seconds for
/// ordinary chatters, 100 per 30 seconds for known broadcasters, moderators, or VIPs,
/// plus a per-channel interval for ordinary chatters that respects slow mode). It is an
/// interactive guardrail rather than a background send queue or a guarantee of Twitch
/// server acceptance.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendEligibility``, ``ChatSendError/refused(_:)``
public struct ChatSendingPolicy: Sendable, Equatable {
  /// Enforces local account-window and per-channel cooldown limits without waiting
  /// automatically unless the caller supplies `waitingForChannelCooldown` on `sendMessage`.
  public static let interactive = Self()
  /// Disables local rate-limit refusals while still validating messages and recording
  /// managed send attempts in the process-local ledger.
  public static let unpaced = Self(enforcesLimits: false)

  /// Whether managed sends enforce process-local account and channel limits.
  public let enforcesLimits: Bool
  /// The minimum interval between consecutive managed sends by an ordinary chatter in the
  /// same channel, clamped to at least 1,001 milliseconds.
  ///
  /// When a channel's observed ``ChatRoomSettings/slowMode`` duration is longer than this
  /// interval, the longer slow-mode duration applies instead.
  public let ordinaryChannelInterval: Duration

  /// Creates a local send pacing policy.
  ///
  /// - Parameters:
  ///   - enforcesLimits: Whether to refuse sends that exceed local pacing limits.
  ///     Defaults to `true`.
  ///   - ordinaryChannelInterval: Minimum delay between managed sends in an ordinary
  ///     channel. Values below `1001` milliseconds are clamped up to `.milliseconds(1001)`.
  ///     Defaults to `.milliseconds(1100)`.
  public init(
    enforcesLimits: Bool = true,
    ordinaryChannelInterval: Duration = .milliseconds(1100)
  ) {
    self.enforcesLimits = enforcesLimits
    self.ordinaryChannelInterval = max(.milliseconds(1001), ordinaryChannelInterval)
  }
}
