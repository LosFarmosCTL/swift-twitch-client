import Foundation
import TwitchIRC

/// Managed chat events. AutoMod hold/review topics are intentionally not included.
public struct ChatEvent: Sendable {
  public enum Payload: Sendable {
    case message(ChatMessage)
    case notification(ChatNotification)
    case messageDeleted(ChatMessageDeletion)
    case messagesCleared(user: ChatUser?)
    case settingsChanged(ChatRoomSettings)
    case moderation(ChatModeration)
    case notice(code: String?, message: String)
    case membershipEnded(ChatDeparture.Reason)
  }

  public let channel: ChatChannel
  /// IRC server time where supplied; EventSub notification-envelope time otherwise.
  /// `nil` means the IRC event did not carry server time, not a fabricated local time.
  public let timestamp: Date?
  public let payload: Payload
}

public struct ChatUser: Sendable, Equatable {
  public let id: String?
  public let login: String?
  public let displayName: String?
}

public struct ChatBadge: Sendable, Equatable {
  public let setID: String
  public let version: String
  public let info: String?
}

public struct ChatMessage: Sendable {
  /// Original transport details remain available without pretending both transports
  /// provide identical metadata (for example IRC emote ranges versus EventSub fragments).
  public enum Details: Sendable {
    case irc(PrivateMessage)
    case eventSub(ChannelChatMessageEvent)
  }

  public let id: String
  public let author: ChatUser
  public let text: String
  public let color: String?
  public let badges: [ChatBadge]
  public let replyToMessageID: String?
  public let clientNonce: String?
  public let isFirstMessage: Bool?
  public let isReturningChatter: Bool?
  /// IRC content-filter flags, or `nil` when empty. No AutoMod bridging.
  public let contentFilterFlags: String?
  /// EventSub `user_intro` is not IRC `first-msg`.
  public let isIntroduction: Bool?
  public let sourceChannelID: String?
  public let sourceMessageID: String?
  public let sourceBadges: [ChatBadge]?
  public let isSourceOnly: Bool?
  public let details: Details
}

public struct ChatNotification: Sendable {
  public enum Details: Sendable {
    case irc(UserNotice)
    /// The underlying modern notice decoded using `source-msg-id`, while the wire
    /// `msg-id` is `sharedchatnotice`.
    case ircSharedChat(UserNotice)
    case eventSub(ChannelChatNotificationEvent)
  }

  /// Notification category, including subscription, raid, announcement and Shared Chat variants.
  public let kind: String
  public let id: String?
  public let author: ChatUser?
  public let text: String?
  public let systemMessage: String?
  public let sourceChannelID: String?
  public let sourceMessageID: String?
  /// Whether Twitch marked the notification as limited to its Shared Chat source.
  public let isSourceOnly: Bool?
  public let details: Details
}

public struct ChatMessageDeletion: Sendable {
  public let messageID: String
  public let author: ChatUser?
  public let text: String?
  public let moderator: ChatUser?
}

public struct ChatModeration: Sendable {
  public enum Action: Sendable {
    case ban(user: ChatUser, reason: String?)
    case timeout(user: ChatUser, until: Date?, duration: Duration?, reason: String?)
    case unban(ChatUser)
    case untimeout(ChatUser)
    /// Retains modern moderation actions not represented by the common cases.
    case eventSub(ChannelModerateEvent.Action)
  }

  public let moderator: ChatUser?
  public let sourceChannelID: String?
  public let action: Action
}
