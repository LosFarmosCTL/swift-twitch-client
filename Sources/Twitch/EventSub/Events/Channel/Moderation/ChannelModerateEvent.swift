import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
// swiftlint:disable:next type_body_length
public struct ChannelModerateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String
  public let sourceBroadcasterID: String?
  public let sourceBroadcasterLogin: String?
  public let sourceBroadcasterDisplayName: String?

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

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
    case addBlockedTerm(AutoModTerm)
    case removeBlockedTerm(AutoModTerm)
    case addPermittedTerm(AutoModTerm)
    case removePermittedTerm(AutoModTerm)
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

    @MemberwiseInit(.public)
    public struct User: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin
        case userDisplayName = "userName"
      }
    }

    @MemberwiseInit(.public)
    public struct Ban: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
      public let reason: String?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason
      }
    }

    @MemberwiseInit(.public)
    public struct Timeout: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
      public let reason: String?
      public let expiresAt: Date

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason, expiresAt
      }
    }

    @MemberwiseInit(.public)
    public struct Raid: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
      public let viewerCount: Int

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, viewerCount
      }
    }

    @MemberwiseInit(.public)
    public struct Delete: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
      public let messageID: String
      public let messageBody: String

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case messageID = "messageId"
        case userLogin, messageBody
      }
    }

    @MemberwiseInit(.public)
    public struct Warn: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
      public let reason: String?
      public let chatRulesCited: [String]?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userDisplayName = "userName"
        case userLogin, reason, chatRulesCited
      }
    }

    @MemberwiseInit(.public)
    public struct AutoModTerm: Codable, Sendable {
      public let terms: [String]
      public let fromAutoMod: Bool

      enum CodingKeys: String, CodingKey {
        case terms
        case fromAutoMod = "fromAutomod"
      }
    }

    @MemberwiseInit(.public)
    public struct UnbanRequest: Codable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String
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
