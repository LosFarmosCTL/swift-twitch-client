import Foundation

/// A resolved Twitch chat channel identified by both its numeric user ID and login name.
///
/// Passing a pre-resolved `ChatChannel` to managed chat methods such as
/// ``TwitchClient/join(to:)-(ChatChannel)``,
/// ``TwitchClient/requestJoin(to:)-(ChatChannel)``, or
/// ``TwitchClient/sendMessage(_:in:replyTo:clientNonce:waitingForChannelCooldown:)-(_,ChatChannel,_,_,_)``
/// avoids an extra Helix user-lookup request—which also allows anonymous IRC readers to
/// join channels without OAuth credentials.
///
/// - SeeAlso: ``ChatChannelTarget``, <doc:ManagedChat>
public struct ChatChannel: Sendable, Equatable, Hashable {
  /// The broadcaster's numeric Twitch user ID.
  public let id: String
  /// The broadcaster's lowercase login name without any leading `#`.
  public let login: String

  /// Creates a channel value, normalizing `login` to lowercase and stripping a leading `#`.
  ///
  /// - Parameters:
  ///   - id: The broadcaster's numeric Twitch user ID.
  ///   - login: The broadcaster's login name (with or without a leading `#`).
  public init(id: String, login: String) {
    self.id = id
    self.login = IRCWireMessage.channelLogin(login)
  }

  internal var isValidForManagedChat: Bool {
    !id.isEmpty && !id.contains(where: { $0.isWhitespace || $0 == "\0" })
      && IRCWireMessage.isLogin(login)
  }
}

/// An unresolved channel identifier passed to managed chat operations.
///
/// Use ``id(_:)`` or ``login(_:)`` when you do not already hold a resolved ``ChatChannel``.
/// The client resolves the target through Helix (or from its local channel cache) before
/// joining, parting, or sending.
///
/// - SeeAlso: ``ChatChannel``, <doc:ManagedChat>
public enum ChatChannelTarget: Sendable, Equatable, Hashable {
  /// The broadcaster's numeric Twitch user ID.
  case id(String)
  /// The broadcaster's login name (with or without a leading `#`).
  case login(String)
}

/// Lifecycle status of a managed chat reader, writer, channel membership, or enrichment.
///
/// - SeeAlso: ``ChatState``, ``ChatChannelState``
public enum ChatComponentStatus: Sendable, Equatable {
  /// The component has not been started yet (or is not needed for current memberships).
  case idle
  /// The component is establishing its connection or EventSub subscriptions.
  case connecting
  /// The component is connected and operational.
  case ready
  /// The component is recovering after a disconnect or credential change.
  case reconnecting
  /// The component cannot run under the current configuration, credentials, or roles.
  ///
  /// Carries a diagnostic explanation (for example, missing scopes or shutdown).
  case unavailable(String)
  /// Setup or transport maintenance failed; carries a diagnostic description.
  case failed(String)
}

/// The current user's known role privileges in a specific chat channel.
///
/// Managed chat uses privilege evidence to select the local send-rate tier (100/30s vs
/// 20/30s and channel cooldown exemption) and to decide whether
/// ``ChatConfiguration/moderationEnrichment`` can subscribe to `channel.moderate`.
///
/// Unknown privilege (``unknown``, where ``isKnown`` is `false`) is intentionally distinct
/// from a positively observed ordinary chatter (`isKnown == true`, all role flags `false`).
///
/// - SeeAlso: ``TwitchClient/setChatPrivilege(_:in:)``, ``ChatChannelState/privilege``
public struct ChatPrivilege: Sendable, Equatable {
  /// Whether the current user is the broadcaster of the channel.
  public var isBroadcaster: Bool
  /// Whether the current user is a moderator of the channel.
  public var isModerator: Bool
  /// Whether the current user is a VIP in the channel.
  public var isVIP: Bool
  /// Whether role evidence has been observed or explicitly supplied (`false` for ``unknown``).
  public var isKnown: Bool
  /// `true` if the user is a broadcaster, moderator, or VIP (eligible for higher send pacing).
  public var isPrivileged: Bool { isBroadcaster || isModerator || isVIP }

  /// Creates a channel privilege value.
  ///
  /// - Parameters:
  ///   - isBroadcaster: Whether the user owns the channel. Defaults to `false`.
  ///   - isModerator: Whether the user is a channel moderator. Defaults to `false`.
  ///   - isVIP: Whether the user is a channel VIP. Defaults to `false`.
  ///   - isKnown: Whether this value represents positive role evidence. Defaults to `true`.
  public init(
    isBroadcaster: Bool = false, isModerator: Bool = false,
    isVIP: Bool = false, isKnown: Bool = true
  ) {
    self.isBroadcaster = isBroadcaster
    self.isModerator = isModerator
    self.isVIP = isVIP
    self.isKnown = isKnown
  }

  /// No role evidence has been observed or supplied yet.
  public static let unknown = Self(isKnown: false)
}

/// Observed chat room restriction settings for a joined channel.
///
/// Populated from IRC `ROOMSTATE` messages, or from Helix `Get Chat Settings` plus
/// EventSub `channel.chat_settings.update` notifications when using an EventSub reader.
///
/// - SeeAlso: ``ChatChannelState/settings``, ``ChatEvent/Payload/settingsChanged(_:)``
public struct ChatRoomSettings: Sendable, Equatable {
  /// Whether emote-only mode is enabled, or `nil` if not yet observed.
  public var emoteOnly: Bool?
  /// Whether subscriber-only mode is enabled, or `nil` if not yet observed.
  public var subscribersOnly: Bool?
  /// Whether unique-chat (R9K) mode is enabled, or `nil` if not yet observed.
  public var uniqueMessages: Bool?
  /// Required follow duration for follower-only mode (`.zero` means any follower), or
  /// `nil` when disabled or not yet observed. Consult ``isKnown`` to distinguish the two.
  public var followersOnly: Duration?
  /// Required delay between messages in slow mode, or `nil` when disabled or not yet
  /// observed. Also influences managed chat's local per-channel send pacing for ordinary chatters.
  public var slowMode: Duration?
  /// `true` once a complete snapshot of all five room settings has been received.
  public var isKnown = false

  /// Creates a `ChatRoomSettings` value.
  public init(
    emoteOnly: Bool? = nil,
    subscribersOnly: Bool? = nil,
    uniqueMessages: Bool? = nil,
    followersOnly: Duration? = nil,
    slowMode: Duration? = nil,
    isKnown: Bool = false
  ) {
    self.emoteOnly = emoteOnly
    self.subscribersOnly = subscribersOnly
    self.uniqueMessages = uniqueMessages
    self.followersOnly = followersOnly
    self.slowMode = slowMode
    self.isKnown = isKnown
  }
}

/// Per-channel membership, room settings, privilege, moderation, and send-eligibility state.
///
/// Stored by channel ID in ``ChatState/channels``.
public struct ChatChannelState: Sendable, Equatable {
  /// The resolved channel identity.
  public let channel: ChatChannel
  /// The current join/readiness lifecycle status for this channel.
  public internal(set) var status: ChatComponentStatus = .connecting
  /// The latest observed chat room restrictions for this channel.
  public internal(set) var settings = ChatRoomSettings()
  /// The effective sender role privileges in this channel.
  public internal(set) var privilege: ChatPrivilege = .unknown
  /// The status of opt-in ``ChatConfiguration/moderationEnrichment`` in this channel.
  public internal(set) var moderation: ChatComponentStatus = .idle
  /// The Twitch revocation reason if the moderation enrichment subscription was revoked.
  public internal(set) var moderationRevocation: EventSubRevocation.Status?
  /// The current local send eligibility for this channel.
  public internal(set) var sending: ChatSendEligibility = .eligible

  /// Creates a `ChatChannelState` value.
  public init(
    channel: ChatChannel,
    status: ChatComponentStatus = .connecting,
    settings: ChatRoomSettings = ChatRoomSettings(),
    privilege: ChatPrivilege = .unknown,
    moderation: ChatComponentStatus = .idle,
    moderationRevocation: EventSubRevocation.Status? = nil,
    sending: ChatSendEligibility = .eligible
  ) {
    self.channel = channel
    self.status = status
    self.settings = settings
    self.privilege = privilege
    self.moderation = moderation
    self.moderationRevocation = moderationRevocation
    self.sending = sending
  }
}

/// Summary of the most recent credential switch applied to managed chat.
///
/// Exposed on ``ChatState/credentialChange`` after
/// ``TwitchClient/switchCredentials(to:chatBehavior:)``.
public struct ChatCredentialChange: Sendable, Equatable {
  /// The monotonically increasing credential revision number after the switch.
  public let revision: UInt64
  /// The previous user ID, or `nil` if the prior credentials had no user identity.
  public let previousUserID: String?
  /// The newly installed user ID, or `nil` if the new credentials have no user identity.
  public let userID: String?
  /// The ``ChatCredentialSwitchBehavior`` policy applied during the switch.
  public let behavior: ChatCredentialSwitchBehavior
  /// `true` if an anonymous IRC reader stayed connected without reconnecting.
  public let anonymousReaderPreserved: Bool

  /// Creates a `ChatCredentialChange` value.
  public init(
    revision: UInt64,
    previousUserID: String? = nil,
    userID: String? = nil,
    behavior: ChatCredentialSwitchBehavior,
    anonymousReaderPreserved: Bool
  ) {
    self.revision = revision
    self.previousUserID = previousUserID
    self.userID = userID
    self.behavior = behavior
    self.anonymousReaderPreserved = anonymousReaderPreserved
  }
}

/// Record of the most recent channel membership that ended in managed chat.
///
/// Exposed on ``ChatState/lastDeparture`` and paired with
/// ``ChatEvent/Payload/membershipEnded(_:)`` on the chat event stream.
public struct ChatDeparture: Sendable, Equatable {
  /// Why managed chat ended membership for a channel.
  public enum Reason: Sendable, Equatable {
    /// The caller parted the channel via `part(...)`.
    case requested
    /// Credentials were switched with ``ChatCredentialSwitchBehavior/partChannels``.
    case credentialsChanged
    /// Twitch revoked a required EventSub chat subscription for this channel.
    case subscriptionRevoked(EventSubRevocation.Status)
    /// A required EventSub chat subscription ended (for example, after a disconnect or
    /// ``TwitchClient/resetEventSub()``); carries a diagnostic description.
    case requiredSubscriptionEnded(String)
    /// Managed chat was permanently stopped via ``TwitchClient/shutdownChat()``.
    case shutdown
  }

  /// The channel whose membership ended.
  public let channel: ChatChannel
  /// Why the channel membership ended.
  public let reason: Reason

  /// Creates a `ChatDeparture` value.
  public init(
    channel: ChatChannel,
    reason: Reason
  ) {
    self.channel = channel
    self.reason = reason
  }
}

/// A point-in-time snapshot of managed chat transports, channels, and send eligibility.
///
/// Read synchronously via ``TwitchClient/chatState`` or stream updates with
/// ``TwitchClient/chatStateUpdates()``. Observing state never opens a network connection.
/// Every snapshot carries its ``credentialRevision`` and ``userID`` so consumers can
/// detect account switches cleanly.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatChannelState``, ``IRCState``
public struct ChatState: Sendable {
  /// Monotonically increasing counter incremented on each
  /// ``TwitchClient/switchCredentials(to:chatBehavior:)``.
  public internal(set) var credentialRevision: UInt64 = 0
  /// The currently installed user ID, or `nil` for non-user credentials.
  public internal(set) var userID: String?
  /// Details of the most recent credential switch, if any has occurred.
  public internal(set) var credentialChange: ChatCredentialChange?
  /// Aggregate status of the configured chat reader transport.
  public internal(set) var reader: ChatComponentStatus = .idle
  /// Aggregate status of the configured chat writer transport.
  public internal(set) var writer: ChatComponentStatus = .idle
  /// Detailed diagnostics for the IRC read pool when using an IRC reader, or `nil`.
  public internal(set) var ircReader: IRCState?
  /// Detailed diagnostics for the dedicated IRC write connection when using an IRC writer, or `nil`.
  public internal(set) var ircWriter: IRCState?
  /// Currently joined or joining channels keyed by Twitch channel ID.
  public internal(set) var channels: [String: ChatChannelState] = [:]
  /// The most recent channel departure, if any channel has been left or lost.
  public internal(set) var lastDeparture: ChatDeparture?
  /// Local send eligibility keyed by channel ID for all joined channels and send targets.
  public internal(set) var sendEligibility: [String: ChatSendEligibility] = [:]
  /// `true` after ``TwitchClient/shutdownChat()`` has been called.
  public internal(set) var isShutdown = false

  /// Creates a `ChatState` value.
  public init(
    credentialRevision: UInt64 = 0,
    userID: String? = nil,
    credentialChange: ChatCredentialChange? = nil,
    reader: ChatComponentStatus = .idle,
    writer: ChatComponentStatus = .idle,
    ircReader: IRCState? = nil,
    ircWriter: IRCState? = nil,
    channels: [String: ChatChannelState] = [:],
    lastDeparture: ChatDeparture? = nil,
    sendEligibility: [String: ChatSendEligibility] = [:],
    isShutdown: Bool = false
  ) {
    self.credentialRevision = credentialRevision
    self.userID = userID
    self.credentialChange = credentialChange
    self.reader = reader
    self.writer = writer
    self.ircReader = ircReader
    self.ircWriter = ircWriter
    self.channels = channels
    self.lastDeparture = lastDeparture
    self.sendEligibility = sendEligibility
    self.isShutdown = isShutdown
  }
}

/// Whether the current account is locally eligible to send a managed chat message in a channel.
///
/// Evaluated from process-local send history, observed bans or timeouts, and client state.
/// Query with ``TwitchClient/sendEligibility(in:)`` or inspect ``ChatState/sendEligibility``.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendingPolicy``, ``ChatSendError/refused(_:)``
public enum ChatSendEligibility: Sendable, Equatable {
  /// Local evidence allows sending now; Twitch or another client can still reject the send.
  case eligible
  /// An ordinary chatter must wait until the per-channel or slow-mode cooldown expires.
  ///
  /// Pass `waitingForChannelCooldown` to `sendMessage` to opt into a bounded wait for this state.
  case channelCooldown(until: Date)
  /// The account's 30-second sliding send window (20 ordinary / 100 privileged) is full.
  ///
  /// Managed sends always refuse this state immediately without waiting.
  case accountWindow(until: Date)
  /// The current account was observed as banned in this channel.
  case banned
  /// The current account was observed as timed out in this channel.
  ///
  /// - Parameter until: When the timeout expires, or `nil` if expiration could not be determined.
  case timedOut(until: Date?)
  /// Sending is unavailable under the current client state (for example, shut down or
  /// non-user credentials); carries a diagnostic explanation.
  case unavailable(String)
}

/// The immediate result of a managed chat send operation.
///
/// Returned by `TwitchClient.sendMessage(...)` overloads.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatSendError``
public enum ChatSendOutcome: Sendable, Equatable {
  /// Helix accepted the message for delivery and returned its Twitch `messageID`.
  case accepted(messageID: String)
  /// The IRC write connection flushed the `PRIVMSG` command to the wire.
  ///
  /// - Important: A successful IRC write is **not** a delivery confirmation. If Twitch
  ///   rejects the message (for example, due to slow mode or AutoMod), a separate
  ///   ``ChatEvent/Payload/notice(code:message:)`` event arrives asynchronously on the
  ///   chat stream and is not correlated back to this call.
  case written(clientNonce: String?)
}
