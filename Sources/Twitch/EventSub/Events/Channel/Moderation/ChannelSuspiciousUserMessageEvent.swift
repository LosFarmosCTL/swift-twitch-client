public struct ChannelSuspiciousUserMessageEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let userID: String
  public let userName: String
  public let userLogin: String

  public let lowTrustStatus: LowTrustStatus
  public let sharedBanChannelIDs: [String]
  public let types: [SuspiciousUserType]
  public let banEvasionEvaluation: BanEvasionEvaluation

  public let message: Message

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case userID = "userId"
    case userName, userLogin

    case types, banEvasionEvaluation, lowTrustStatus
    case sharedBanChannelIDs = "sharedBanChannelIds"
    case message
  }

  public enum LowTrustStatus: String, Codable, Sendable {
    case none, restricted
    case activeMonitoring = "active_monitoring"
  }

  public enum SuspiciousUserType: String, Codable, Sendable {
    case manuallyAdded = "manually_added"
    case banEvader = "ban_evader"
    case bannedInSharedChannel = "banned_in_shared_channel"
  }

  public enum BanEvasionEvaluation: String, Codable, Sendable {
    case unknown, possible, likely
  }

  public struct Message: Decodable, Sendable {
    public let id: String
    public let text: String
    public let fragments: [Fragment]

    enum CodingKeys: String, CodingKey {
      case id = "messageId"
      case text, fragments
    }

    public struct Fragment: Decodable, Sendable {
      public let text: String
      public let type: FragmentType

      enum CodingKeys: String, CodingKey {
        case text, type
      }

      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        type = try FragmentType(from: decoder)
      }

      public enum FragmentType: Sendable {
        case emote(Emote)
        case cheermote(Cheermote)
        case text

        enum CodingKeys: String, CodingKey {
          case type, emote, cheermote
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let type = try container.decode(FragmentType.self, forKey: .type)

          switch type {
          case .emote:
            self = .emote(try container.decode(Emote.self, forKey: .emote))
          case .cheermote:
            self = .cheermote(try container.decode(Cheermote.self, forKey: .cheermote))
          case .text:
            self = .text
          }
        }

        private enum FragmentType: String, Decodable, Sendable {
          case emote, cheermote, text
        }
      }

      public struct Emote: Decodable, Sendable {
        public let id: String
        public let emoteSetID: String

        enum CodingKeys: String, CodingKey {
          case id
          case emoteSetID = "emoteSetId"
        }
      }

      public struct Cheermote: Decodable, Sendable {
        public let prefix: String
        public let bits: Int
        public let tier: Int
      }
    }
  }
}
