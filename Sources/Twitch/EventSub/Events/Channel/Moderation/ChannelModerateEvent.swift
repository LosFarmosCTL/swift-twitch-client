import Foundation
import MemberwiseInit

/// An EventSub notification for channel moderate.
@MemberwiseInit(.public)
// swiftlint:disable:next type_body_length
public struct ChannelModerateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The Twitch user ID of the source broadcaster, when provided.
  public let sourceBroadcasterID: String?
  /// The login name of the source broadcaster, when provided.
  public let sourceBroadcasterLogin: String?
  /// The display name of the source broadcaster, when provided.
  public let sourceBroadcasterDisplayName: String?

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  /// The action and any associated details.
  public let action: Action

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case sourceBroadcasterID = "sourceBroadcasterUserId"
    case sourceBroadcasterLogin = "sourceBroadcasterUserLogin"
    case sourceBroadcasterDisplayName = "sourceBroadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case action
    case followers
    case slow
    case vip
    case unvip
    case mod
    case unmod
    case ban
    case unban
    case timeout
    case untimeout
    case raid
    case unraid
    case delete
    case autoModTerms = "automodTerms"
    case unbanRequest
    case warn
    case sharedChatBan
    case sharedChatTimeout
    case sharedChatUnban
    case sharedChatUntimeout
    case sharedChatDelete
  }

  /// Decodes a moderation event and its action-specific payload.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    sourceBroadcasterID = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterID)
    sourceBroadcasterLogin = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterLogin)
    sourceBroadcasterDisplayName = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterDisplayName)
    moderatorID = try container.decode(String.self, forKey: .moderatorID)
    moderatorLogin = try container.decode(String.self, forKey: .moderatorLogin)
    moderatorDisplayName = try container.decode(
      String.self, forKey: .moderatorDisplayName)

    action = try Action(from: decoder)
  }

  /// The moderation operation and any affected user, message, terms, or settings.
  public enum Action: Sendable {
    /// Bans the associated user, with the moderator’s reason.
    case ban(Ban)
    /// Times out the associated user until the supplied expiration.
    case timeout(Timeout)
    /// Removes the associated user’s ban.
    case unban(User)
    /// Ends the associated user’s timeout.
    case untimeout(User)
    /// Clears all messages from the channel’s chat.
    case clear
    /// Enables chat messages containing only emotes.
    case emoteOnly
    /// Disables emote-only chat.
    case emoteOnlyOff
    /// Enables follower-only chat with the required following duration.
    case followerMode(Duration)
    /// Disables follower-only chat.
    case followerModeOff
    /// Enables the restriction on duplicate chat messages.
    case uniqueChat
    /// Disables the restriction on duplicate chat messages.
    case uniqueChatOff
    /// Enables slow mode with the minimum interval between messages.
    case slow(Duration)
    /// Disables slow mode.
    case slowOff
    /// Restricts chat to subscribers.
    case subOnlyMode
    /// Disables subscriber-only chat.
    case subOnlyModeOff
    /// Starts a raid of the associated channel with the supplied viewer count.
    case raid(Raid)
    /// Cancels the raid to the associated channel.
    case unraid(User)
    /// Grants VIP status to the associated user.
    case vip(User)
    /// Removes VIP status from the associated user.
    case unvip(User)
    /// Grants moderator privileges to the associated user.
    case mod(User)
    /// Removes moderator privileges from the associated user.
    case unmod(User)
    /// Deletes the associated message; includes its author and original text.
    case delete(Delete)
    /// Warns the associated user with a reason and any cited chat rules.
    case warn(Warn)
    /// Adds the associated terms to the channel’s blocked list.
    case addBlockedTerm(AutoModTerm)
    /// Removes the associated terms from the channel’s blocked list.
    case removeBlockedTerm(AutoModTerm)
    /// Adds the associated terms to the channel’s permitted list.
    case addPermittedTerm(AutoModTerm)
    /// Removes the associated terms from the channel’s permitted list.
    case removePermittedTerm(AutoModTerm)
    /// Approves the associated user’s unban request, with the moderator’s response.
    case approveUnbanRequest(UnbanRequest)
    /// Denies the associated user’s unban request, with the moderator’s response.
    case denyUnbanRequest(UnbanRequest)
    /// Bans the associated user in the source channel during shared chat.
    case sharedChatBan(Ban)
    /// Times out the associated user in the source channel during shared chat.
    case sharedChatTimeout(Timeout)
    /// Removes the associated user’s ban in the source channel during shared chat.
    case sharedChatUnban(User)
    /// Ends the associated user’s timeout in the source channel during shared chat.
    case sharedChatUntimeout(User)
    /// Deletes the associated message from the source channel during shared chat.
    case sharedChatDelete(Delete)

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      switch try container.decode(ActionType.self, forKey: .action) {
      case .ban:
        self = .ban(try container.decode(Ban.self, forKey: .ban))
      case .timeout:
        self = .timeout(try container.decode(Timeout.self, forKey: .timeout))
      case .unban:
        self = .unban(try container.decode(User.self, forKey: .unban))
      case .untimeout:
        self = .untimeout(try container.decode(User.self, forKey: .untimeout))
      case .clear:
        self = .clear
      case .emoteOnly:
        self = .emoteOnly
      case .emoteOnlyOff:
        self = .emoteOnlyOff
      case .followerMode:
        let followerMode = try container.decode(FollowerMode.self, forKey: .followers)
        self = .followerMode(.seconds(followerMode.followDurationMinutes * 60))
      case .followerModeOff:
        self = .followerModeOff
      case .uniqueChat:
        self = .uniqueChat
      case .uniqueChatOff:
        self = .uniqueChatOff
      case .slow:
        let slowMode = try container.decode(SlowMode.self, forKey: .slow)
        self = .slow(.seconds(slowMode.waitTimeSeconds))
      case .slowOff:
        self = .slowOff
      case .subOnlyMode:
        self = .subOnlyMode
      case .subOnlyModeOff:
        self = .subOnlyModeOff
      case .raid:
        self = .raid(try container.decode(Raid.self, forKey: .raid))
      case .unraid:
        self = .unraid(try container.decode(User.self, forKey: .unraid))
      case .vip:
        self = .vip(try container.decode(User.self, forKey: .vip))
      case .unvip:
        self = .unvip(try container.decode(User.self, forKey: .unvip))
      case .mod:
        self = .mod(try container.decode(User.self, forKey: .mod))
      case .unmod:
        self = .unmod(try container.decode(User.self, forKey: .unmod))
      case .delete:
        self = .delete(try container.decode(Delete.self, forKey: .delete))
      case .warn:
        self = .warn(try container.decode(Warn.self, forKey: .warn))
      case .addBlockedTerm:
        self = .addBlockedTerm(
          try container.decode(AutoModTerm.self, forKey: .autoModTerms))
      case .removeBlockedTerm:
        self = .removeBlockedTerm(
          try container.decode(AutoModTerm.self, forKey: .autoModTerms))
      case .addPermittedTerm:
        self = .addPermittedTerm(
          try container.decode(AutoModTerm.self, forKey: .autoModTerms))
      case .removePermittedTerm:
        self = .removePermittedTerm(
          try container.decode(AutoModTerm.self, forKey: .autoModTerms))
      case .approveUnbanRequest:
        self = .approveUnbanRequest(
          try container.decode(UnbanRequest.self, forKey: .unbanRequest))
      case .denyUnbanRequest:
        self = .denyUnbanRequest(
          try container.decode(UnbanRequest.self, forKey: .unbanRequest))
      case .sharedChatBan:
        self = .sharedChatBan(try container.decode(Ban.self, forKey: .sharedChatBan))
      case .sharedChatTimeout:
        self = .sharedChatTimeout(
          try container.decode(Timeout.self, forKey: .sharedChatTimeout))
      case .sharedChatUnban:
        self = .sharedChatUnban(try container.decode(User.self, forKey: .sharedChatUnban))
      case .sharedChatUntimeout:
        self = .sharedChatUntimeout(
          try container.decode(User.self, forKey: .sharedChatUntimeout))
      case .sharedChatDelete:
        self = .sharedChatDelete(
          try container.decode(Delete.self, forKey: .sharedChatDelete))
      }
    }

    enum ActionType: String, Codable {
      case ban, timeout
      case unban, untimeout
      case clear
      case emoteOnly = "emoteonly"
      case emoteOnlyOff = "emoteonlyoff"
      case followerMode = "followers"
      case followerModeOff = "followersoff"
      case uniqueChat = "uniquechat"
      case uniqueChatOff = "uniquechatoff"
      case slow
      case slowOff = "slowoff"
      case subOnlyMode = "subscribers"
      case subOnlyModeOff = "subscribersoff"
      case raid, unraid
      case vip, unvip
      case mod, unmod
      case delete, warn
      case addBlockedTerm = "add_blocked_term"
      case removeBlockedTerm = "remove_blocked_term"
      case addPermittedTerm = "add_permitted_term"
      case removePermittedTerm = "remove_permitted_term"
      case approveUnbanRequest = "approve_unban_request"
      case denyUnbanRequest = "deny_unban_request"
      case sharedChatBan = "shared_chat_ban"
      case sharedChatTimeout = "shared_chat_timeout"
      case sharedChatUnban = "shared_chat_unban"
      case sharedChatUntimeout = "shared_chat_untimeout"
      case sharedChatDelete = "shared_chat_delete"
    }

    /// The account identity of a user affected by a moderation action.
    @MemberwiseInit(.public)
    public struct User: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin
        case userDisplayName = "userName"
      }
    }

    /// The banned user’s account identity and the moderator’s reason.
    @MemberwiseInit(.public)
    public struct Ban: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The reason supplied for this action, when provided.
      public let reason: String?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason
      }
    }

    /// The timed-out user’s account identity, reason, and timeout expiration.
    @MemberwiseInit(.public)
    public struct Timeout: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The reason supplied for this action, when provided.
      public let reason: String?
      /// The time the resource expires.
      public let expiresAt: Date

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason, expiresAt
      }
    }

    /// The raid target’s account identity and the number of viewers joining the raid.
    @MemberwiseInit(.public)
    public struct Raid: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The number of viewers reported by Twitch.
      public let viewerCount: Int

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, viewerCount
      }
    }

    /// The deleted message’s author, identifier, and original text.
    @MemberwiseInit(.public)
    public struct Delete: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The identifier of the message.
      public let messageID: String
      /// The body of the chat message.
      public let messageBody: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case messageID = "messageId"
        case userLogin, messageBody
      }
    }

    /// The warned user’s account identity, reason, and any cited chat rules.
    @MemberwiseInit(.public)
    public struct Warn: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The reason supplied for this action, when provided.
      public let reason: String?
      /// The channel chat rules cited in the warning, when provided.
      public let chatRulesCited: [String]?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason, chatRulesCited
      }
    }

    /// Terms added or removed and whether the change followed an AutoMod decision.
    @MemberwiseInit(.public)
    public struct AutoModTerm: Codable, Sendable {
      /// The AutoMod terms affected by the action.
      public let terms: [String]
      /// Whether AutoMod originated the action.
      public let fromAutoMod: Bool

      enum CodingKeys: String, CodingKey {
        case terms
        case fromAutoMod = "fromAutomod"
      }
    }

    /// The requesting user’s account identity and the moderator’s response message.
    @MemberwiseInit(.public)
    public struct UnbanRequest: Codable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The message supplied by the moderator.
      public let moderatorMessage: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, moderatorMessage
      }
    }

    private struct FollowerMode: Codable, Sendable {
      let followDurationMinutes: Int
    }

    private struct SlowMode: Codable, Sendable {
      let waitTimeSeconds: Int
    }
  }
}
