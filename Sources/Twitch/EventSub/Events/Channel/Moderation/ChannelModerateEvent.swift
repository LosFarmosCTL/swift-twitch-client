import Foundation

// swiftlint:disable:next type_body_length
public struct ChannelModerateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String
  public let sourceBroadcasterID: String?
  public let sourceBroadcasterLogin: String?
  public let sourceBroadcasterName: String?

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let action: Action

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case sourceBroadcasterID = "sourceBroadcasterUserId"
    case sourceBroadcasterLogin = "sourceBroadcasterUserLogin"
    case sourceBroadcasterName = "sourceBroadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case action, followers, slow, vip, unvip, mod, unmod, ban, unban, timeout, untimeout,
      raid, unraid, delete, automodTerms, unbanRequest, warn, sharedChatBan,
      sharedChatTimeout, sharedChatUnban, sharedChatUntimeout, sharedChatDelete
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
    sourceBroadcasterID = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterID)
    sourceBroadcasterLogin = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterLogin)
    sourceBroadcasterName = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterName)
    moderatorID = try container.decode(String.self, forKey: .moderatorID)
    moderatorLogin = try container.decode(String.self, forKey: .moderatorLogin)
    moderatorName = try container.decode(String.self, forKey: .moderatorName)

    action = try Action(from: decoder)
  }

  public enum Action: Sendable {
    case ban(Ban)
    case timeout(Timeout)
    case unban(User)
    case untimeout(User)
    case clear
    case emoteOnly
    case emoteOnlyOff
    case followerMode(Duration)
    case followerModeOff
    case uniqueChat
    case uniqueChatOff
    case slow(Duration)
    case slowOff
    case subOnlyMode
    case subOnlyModeOff
    case raid(Raid)
    case unraid(User)
    case vip(User)
    case unvip(User)
    case mod(User)
    case unmod(User)
    case delete(Delete)
    case warn(Warn)
    case addBlockedTerm(AutomodTerm)
    case removeBlockedTerm(AutomodTerm)
    case addPermittedTerm(AutomodTerm)
    case removePermittedTerm(AutomodTerm)
    case approveUnbanRequest(UnbanRequest)
    case denyUnbanRequest(UnbanRequest)
    case sharedChatBan(Ban)
    case sharedChatTimeout(Timeout)
    case sharedChatUnban(User)
    case sharedChatUntimeout(User)
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
          try container.decode(AutomodTerm.self, forKey: .automodTerms))
      case .removeBlockedTerm:
        self = .removeBlockedTerm(
          try container.decode(AutomodTerm.self, forKey: .automodTerms))
      case .addPermittedTerm:
        self = .addPermittedTerm(
          try container.decode(AutomodTerm.self, forKey: .automodTerms))
      case .removePermittedTerm:
        self = .removePermittedTerm(
          try container.decode(AutomodTerm.self, forKey: .automodTerms))
      case .approveUnbanRequest:
        self = .approveUnbanRequest(
          try container.decode(UnbanRequest.self, forKey: .automodTerms))
      case .denyUnbanRequest:
        self = .denyUnbanRequest(
          try container.decode(UnbanRequest.self, forKey: .automodTerms))
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

    public struct User: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
      }
    }

    public struct Ban: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let reason: String?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case reason
      }
    }

    public struct Timeout: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let reason: String?
      public let expiresAt: Date

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case reason, expiresAt
      }
    }

    public struct Raid: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let viewerCount: Int

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case viewerCount
      }
    }

    public struct Delete: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let messageID: String
      public let messageBody: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case messageID = "messageId"
        case messageBody
      }
    }

    public struct Warn: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let reason: String?
      public let chatRulesCited: [String]?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case reason, chatRulesCited
      }
    }

    public struct AutomodTerm: Codable, Sendable {
      public let terms: [String]
      public let fromAutomod: Bool
    }

    public struct UnbanRequest: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String
      public let moderatorMessage: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName
        case moderatorMessage
      }
    }

    private struct FollowerMode: Codable, Sendable {
      public let followDurationMinutes: Int
    }

    private struct SlowMode: Codable, Sendable {
      public let waitTimeSeconds: Int
    }
  }
}
