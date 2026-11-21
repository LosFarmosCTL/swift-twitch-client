import Foundation
public import TwitchIRC

/// A normalized event emitted by ``TwitchClient/messageStream(bufferingPolicy:)``.
///
/// Managed chat normalizes IRC and EventSub chat traffic into a shared event model while
/// keeping transport-specific payloads accessible on ``ChatMessage/details`` and
/// ``ChatNotification/details``. AutoMod hold and review topics are intentionally excluded;
/// subscribe to those directly with ``TwitchClient/eventStream(for:bufferingPolicy:)``.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatState``, ``ChatChannel``
public struct ChatEvent: Sendable {
  /// The specific chat activity represented by a ``ChatEvent``.
  public enum Payload: Sendable {
    /// A regular chat message sent by a viewer.
    case message(ChatMessage)
    /// A channel notice such as a subscription, raid, announcement, or Shared Chat notice.
    case notification(ChatNotification)
    /// A single chat message was deleted.
    case messageDeleted(ChatMessageDeletion)
    /// All messages in the channel (when `user` is `nil`) or all messages by a specific
    /// user were cleared.
    case messagesCleared(user: ChatUser?)
    /// The channel's chat room settings (slow mode, follower-only, emote-only, etc.) changed.
    case settingsChanged(ChatRoomSettings)
    /// A moderation action observed from IRC `CLEARCHAT` or opt-in EventSub
    /// ``ChatConfiguration/moderationEnrichment``.
    case moderation(ChatModeration)
    /// A channel-scoped IRC `NOTICE` (for example, a send rejection such as `msg_banned`
    /// or `msg_slowmode`).
    ///
    /// - Parameters:
    ///   - code: Twitch's `msg-id` tag, if present.
    ///   - message: The human-readable notice text supplied by Twitch.
    case notice(code: String?, message: String)
    /// Managed membership in the channel ended for the reported reason.
    case membershipEnded(ChatDeparture.Reason)
  }

  /// The channel where this event occurred.
  public let channel: ChatChannel
  /// The server timestamp supplied by Twitch, if available.
  ///
  /// Uses IRC's `tmi-sent-ts` tag when reading via IRC, or EventSub's notification
  /// envelope `sentAt` when reading via EventSub. A `nil` value indicates Twitch did not
  /// attach a server timestamp—the client never fabricates a local wall-clock time.
  public let timestamp: Date?
  /// The local wall-clock time when the client received this event.
  public let receivedAt: Date
  /// The normalized event payload.
  public let payload: Payload

  /// Creates a `ChatEvent` value.
  public init(
    channel: ChatChannel,
    timestamp: Date? = nil,
    receivedAt: Date = Date(),
    payload: Payload
  ) {
    self.channel = channel
    self.timestamp = timestamp
    self.receivedAt = receivedAt
    self.payload = payload
  }
}

/// Identifying fields for a chatter or moderator in managed chat events.
///
/// Depending on the underlying transport and event type (for example, IRC `CLEARMSG` vs
/// EventSub notifications), only a subset of fields may be populated.
public struct ChatUser: Sendable, Equatable {
  /// The user's numeric Twitch user ID, when supplied by the transport.
  public let id: String?
  /// The user's login name, when supplied by the transport.
  public let login: String?
  /// The user's display name, when supplied by the transport.
  public let displayName: String?

  /// Creates a `ChatUser` value.
  public init(
    id: String? = nil,
    login: String? = nil,
    displayName: String? = nil
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
  }
}

/// A normalized chat badge attached to a ``ChatMessage``.
public struct ChatBadge: Sendable, Equatable {
  /// The badge set identifier (for example, `"moderator"`, `"subscriber"`, or `"vip"`).
  public let setID: String
  /// The badge version within the set (for example, `"1"` or `"12"`).
  public let version: String
  /// Optional metadata associated with the badge (such as cumulative subscribed months).
  public let info: String?

  /// Creates a `ChatBadge` value.
  public init(
    setID: String,
    version: String,
    info: String? = nil
  ) {
    self.setID = setID
    self.version = version
    self.info = info
  }
}

/// An occurrence of a Twitch emote in a managed chat message.
public struct ChatEmote: Sendable, Hashable {
  /// The emote identifier supplied by Twitch.
  public let id: String
  /// The emote's text in the message.
  public let name: String
  /// The half-open range of Unicode scalar offsets in the enclosing ``ChatMessage/text``.
  public let range: MessageTextRange

  /// Creates an emote occurrence with a range in the enclosing message's text.
  public init(id: String, name: String, range: MessageTextRange) {
    self.id = id
    self.name = name
    self.range = range
  }
}

/// A normalized chat message received from either IRC or EventSub.
///
/// Use ``text``, ``isAction``, and ``emotes`` to render messages from either transport.
/// Inspect ``details`` for transport-native fields such as EventSub emote formats.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatEvent/Payload/message(_:)``
public struct ChatMessage: Sendable {
  /// The underlying transport-native message model.
  public enum Details: Sendable {
    /// The parsed `TwitchIRC.PrivateMessage` received over IRC.
    case irc(PrivateMessage)
    /// The decoded ``ChannelChatMessageEvent`` received over EventSub.
    case eventSub(ChannelChatMessageEvent)
  }

  /// Twitch's unique identifier for this message.
  public let id: String
  /// The user who sent the message.
  public let author: ChatUser
  /// The displayable message text with CTCP ACTION framing removed.
  public let text: String
  /// Whether the message was sent using the `/me` command.
  public let isAction: Bool
  /// Twitch emote occurrences in ``text``, ordered by their starting offset.
  public let emotes: [ChatEmote]
  /// The author's hex chat color (for example, `"#1E90FF"`), or `nil` if unset.
  public let color: String?
  /// The author's chat badges in this channel.
  public let badges: [ChatBadge]
  /// The parent message ID if this message is a reply, or `nil` for top-level messages.
  public let replyToMessageID: String?
  /// The client-supplied nonce echoed by IRC, or `nil` when absent or read via EventSub.
  public let clientNonce: String?
  /// Whether IRC flagged this as the chatter's first message in the channel (`first-msg`),
  /// or `nil` when read via EventSub.
  public let isFirstMessage: Bool?
  /// Whether IRC flagged this chatter as returning (`returning-chatter`), or `nil` when
  /// read via EventSub.
  public let isReturningChatter: Bool?
  /// Raw IRC content-filter flags (`flags` tag), or `nil` when empty or read via EventSub.
  public let contentFilterFlags: String?
  /// Whether EventSub classified this message as ``ChannelChatMessageEvent/MessageType/userIntro``,
  /// or `nil` when read via IRC.
  ///
  /// EventSub's `user_intro` is distinct from IRC's ``isFirstMessage`` (`first-msg`).
  public let isIntroduction: Bool?
  /// The originating broadcaster's user ID during Shared Chat, or `nil` if not shared.
  public let sourceChannelID: String?
  /// The originating message ID during Shared Chat, or `nil` if not shared.
  public let sourceMessageID: String?
  /// The author's badges in the originating Shared Chat channel, when provided.
  public let sourceBadges: [ChatBadge]?
  /// Whether Twitch restricted this message to its Shared Chat source channel, when provided.
  public let isSourceOnly: Bool?
  /// The raw IRC or EventSub payload for accessing transport-specific metadata.
  public let details: Details

  /// Creates a `ChatMessage` with displayable text and emote ranges relative to that text.
  /// Pass emotes in message order.
  public init(
    id: String,
    author: ChatUser,
    text: String,
    isAction: Bool = false,
    emotes: [ChatEmote] = [],
    color: String? = nil,
    badges: [ChatBadge] = [],
    replyToMessageID: String? = nil,
    clientNonce: String? = nil,
    isFirstMessage: Bool? = nil,
    isReturningChatter: Bool? = nil,
    contentFilterFlags: String? = nil,
    isIntroduction: Bool? = nil,
    sourceChannelID: String? = nil,
    sourceMessageID: String? = nil,
    sourceBadges: [ChatBadge]? = nil,
    isSourceOnly: Bool? = nil,
    details: Details
  ) {
    self.id = id
    self.author = author
    self.text = text
    self.isAction = isAction
    self.emotes = emotes
    self.color = color
    self.badges = badges
    self.replyToMessageID = replyToMessageID
    self.clientNonce = clientNonce
    self.isFirstMessage = isFirstMessage
    self.isReturningChatter = isReturningChatter
    self.contentFilterFlags = contentFilterFlags
    self.isIntroduction = isIntroduction
    self.sourceChannelID = sourceChannelID
    self.sourceMessageID = sourceMessageID
    self.sourceBadges = sourceBadges
    self.isSourceOnly = isSourceOnly
    self.details = details
  }
}

/// A normalized channel notification such as a subscription, raid, or announcement.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatEvent/Payload/notification(_:)``
public struct ChatNotification: Sendable {
  /// The underlying transport-native notification payload.
  public enum Details: Sendable {
    /// A standard `TwitchIRC.UserNotice` received over IRC.
    case irc(UserNotice)
    /// A Shared Chat `TwitchIRC.UserNotice` whose wire `msg-id` was `sharedchatnotice`
    /// and whose underlying notice kind was decoded from `source-msg-id`.
    case ircSharedChat(UserNotice)
    /// A decoded ``ChannelChatNotificationEvent`` received over EventSub.
    case eventSub(ChannelChatNotificationEvent)
  }

  /// Normalized notification category string (such as `"sub"`, `"resub"`, `"raid"`,
  /// `"announcement"`, or `"shared_chat_sub"`).
  public let kind: String
  /// Twitch's identifier for this notification message, when supplied.
  public let id: String?
  /// The user associated with the notification, or `nil` for anonymous notices.
  public let author: ChatUser?
  /// Optional user-authored message text accompanying the notification.
  public let text: String?
  /// Twitch's formatted system banner text (for example, `"alice subscribed at Tier 1."`).
  public let systemMessage: String?
  /// The originating broadcaster's user ID during Shared Chat, or `nil` if not shared.
  public let sourceChannelID: String?
  /// The originating message ID during Shared Chat, or `nil` if not shared.
  public let sourceMessageID: String?
  /// Whether Twitch restricted this notification to its Shared Chat source channel, when
  /// provided (EventSub only; `nil` on IRC).
  public let isSourceOnly: Bool?
  /// The raw IRC or EventSub payload for accessing notice-specific fields.
  public let details: Details

  /// Creates a `ChatNotification` value.
  public init(
    kind: String,
    id: String? = nil,
    author: ChatUser? = nil,
    text: String? = nil,
    systemMessage: String? = nil,
    sourceChannelID: String? = nil,
    sourceMessageID: String? = nil,
    isSourceOnly: Bool? = nil,
    details: Details
  ) {
    self.kind = kind
    self.id = id
    self.author = author
    self.text = text
    self.systemMessage = systemMessage
    self.sourceChannelID = sourceChannelID
    self.sourceMessageID = sourceMessageID
    self.isSourceOnly = isSourceOnly
    self.details = details
  }
}

/// Details of a single deleted chat message.
///
/// Produced by IRC `CLEARMSG` or EventSub `channel.chat.message_delete`. Duplicate
/// deletion IDs for the same channel are deduplicated locally.
///
/// - SeeAlso: ``ChatEvent/Payload/messageDeleted(_:)``
public struct ChatMessageDeletion: Sendable, Equatable {
  /// The Twitch ID of the deleted message.
  public let messageID: String
  /// The deleted message's author, when supplied by the transport.
  public let author: ChatUser?
  /// The deleted message's text (available on IRC `CLEARMSG`; `nil` on EventSub).
  public let text: String?
  /// The moderator who deleted the message, when available.
  public let moderator: ChatUser?

  /// Creates a `ChatMessageDeletion` value.
  public init(
    messageID: String,
    author: ChatUser? = nil,
    text: String? = nil,
    moderator: ChatUser? = nil
  ) {
    self.messageID = messageID
    self.author = author
    self.text = text
    self.moderator = moderator
  }
}

/// A moderation event emitted from IRC `CLEARCHAT` or opt-in EventSub moderation enrichment.
///
/// When ``ChatConfiguration/moderationEnrichment`` is enabled alongside an IRC reader,
/// both IRC and EventSub can report the same ban or timeout independently, with EventSub
/// supplying richer fields such as ``moderator`` and ban/timeout reasons.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatEvent/Payload/moderation(_:)``,
///   ``ChatConfiguration/moderationEnrichment``
public struct ChatModeration: Sendable {
  /// The specific moderation action performed.
  public enum Action: Sendable {
    /// A user was permanently banned from the channel.
    ///
    /// - Parameters:
    ///   - user: The banned user.
    ///   - reason: The moderation reason, when provided by EventSub (`nil` on IRC).
    case ban(user: ChatUser, reason: String?)
    /// A user was temporarily timed out in the channel.
    ///
    /// - Parameters:
    ///   - user: The timed-out user.
    ///   - until: The timeout expiration timestamp, when available. On IRC `CLEARCHAT`
    ///     without `tmi-sent-ts`, computed from ``ChatEvent/receivedAt`` plus the timeout
    ///     duration.
    ///   - duration: The timeout duration. Supplied directly on IRC `CLEARCHAT`; derived on
    ///     EventSub from `until` relative to the notification timestamp (or
    ///     ``ChatEvent/receivedAt``), rounded up to whole seconds with a minimum of 1 second.
    ///   - reason: The moderation reason, when provided by EventSub (`nil` on IRC).
    case timeout(user: ChatUser, until: Date?, duration: Duration?, reason: String?)
    /// A user's ban was lifted (requires EventSub moderation enrichment).
    case unban(ChatUser)
    /// A user's timeout was lifted (requires EventSub moderation enrichment).
    case untimeout(ChatUser)
    /// A modern EventSub moderation action not represented by the common ban/timeout cases
    /// (such as warnings, AutoMod term updates, VIP/mod changes, or unban requests).
    case eventSub(ChannelModerateEvent.Action)
  }

  /// The moderator who performed the action, or `nil` when reported via IRC `CLEARCHAT`.
  public let moderator: ChatUser?
  /// The originating broadcaster's user ID for a Shared Chat moderation action, or `nil`.
  public let sourceChannelID: String?
  /// The moderation action and its associated details.
  public let action: Action

  /// Creates a `ChatModeration` value.
  public init(
    moderator: ChatUser? = nil,
    sourceChannelID: String? = nil,
    action: Action
  ) {
    self.moderator = moderator
    self.sourceChannelID = sourceChannelID
    self.action = action
  }
}
