import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelChatMessageEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let chatterID: String
  public let chatterLogin: String
  public let chatterDisplayName: String

  public let messageID: String
  public let message: Message

  public let messageType: MessageType
  public let color: String?
  public let badges: [Badge]
  public let reply: Reply?

  public let cheer: Cheer?

  public let channelPointsCustomRewardID: String?

  public let sourceBroadcasterID: String?
  public let sourceBroadcasterLogin: String?
  public let sourceBroadcasterDisplayName: String?
  public let sourceMessageID: String?
  public let sourceBadges: [Badge]?
  public let isSourceOnly: Bool?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case chatterID = "chatterUserId"
    case chatterLogin = "chatterUserLogin"
    case chatterDisplayName = "chatterUserName"
    case messageID = "messageId"
    case message
    case color
    case badges
    case reply
    case messageType
    case cheer
    case channelPointsCustomRewardID = "channelPointsCustomRewardId"
    case sourceBroadcasterID = "sourceBroadcasterUserId"
    case sourceBroadcasterLogin = "sourceBroadcasterUserLogin"
    case sourceBroadcasterDisplayName = "sourceBroadcasterUserName"
    case sourceMessageID = "sourceMessageId"
    case sourceBadges
    case isSourceOnly
  }

  public enum MessageType: String, Decodable, Sendable {
    case text = "text"
    case channelPointsHighlighted = "channel_points_highlighted"
    case channelPointsSubOnly = "channel_points_sub_only"
    case userIntro = "user_intro"
    case powerUpsMessageEffect = "power_ups_message_effect"
    case powerUpsGigantifiedEmote = "power_ups_gigantified_emote"
  }

  @MemberwiseInit(.public)
  public struct Badge: Decodable, Sendable {
    public let setID: String
    public let id: String
    public let info: String

    enum CodingKeys: String, CodingKey {
      case setID = "setId"
      case id, info
    }
  }

  @MemberwiseInit(.public)
  public struct Reply: Decodable, Sendable {
    public let parentID: String
    public let parentBody: String

    public let parentUserID: String
    public let parentUserLogin: String
    public let parentUserDisplayName: String

    public let threadID: String
    public let threadUserID: String
    public let threadUserLogin: String
    public let threadUserDisplayName: String

    enum CodingKeys: String, CodingKey {
      case parentID = "parentMessageId"
      case parentBody = "parentMessageBody"
      case parentUserID = "parentUserId"
      case parentUserLogin
      case parentUserDisplayName = "parentUserName"
      case threadID = "threadMessageId"
      case threadUserID = "threadUserId"
      case threadUserLogin
      case threadUserDisplayName = "threadUserName"
    }
  }

  @MemberwiseInit(.public)
  public struct Cheer: Decodable, Sendable {
    public let bits: Int
  }

  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
    public let text: String
    public let fragments: [Fragment]

    enum CodingKeys: String, CodingKey {
      case text
      case fragments
    }

    @MemberwiseInit(.public)
    public struct Fragment: Decodable, Sendable {
      public let type: FragmentType
      public let text: String

      enum CodingKeys: String, CodingKey {
        case type
        case text
      }

      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.text = try container.decode(String.self, forKey: .text)
        self.type = try FragmentType(from: decoder)
      }

      public enum FragmentType: Sendable {
        case text
        case emote(Emote)
        case cheermote(Cheermote)
        case mention(Mention)
        case gif(GIF)

        enum CodingKeys: String, CodingKey {
          case type
          case emote
          case cheermote
          case mention
          case gif
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let type = try container.decode(FragmentType.self, forKey: .type)

          switch type {
          case .text:
            self = .text
          case .emote:
            self = .emote(try container.decode(Emote.self, forKey: .emote))
          case .cheermote:
            self = .cheermote(try container.decode(Cheermote.self, forKey: .cheermote))
          case .mention:
            self = .mention(try container.decode(Mention.self, forKey: .mention))
          case .gif:
            self = .gif(try container.decode(GIF.self, forKey: .gif))
          }
        }

        private enum FragmentType: String, Decodable, Sendable {
          case text, emote, cheermote, mention, gif
        }
      }

      @MemberwiseInit(.public)
      public struct GIF: Decodable, Sendable {
        public let gifID: String
        public let url: String

        enum CodingKeys: String, CodingKey {
          case gifID = "gifId"
          case url
        }
      }

      @MemberwiseInit(.public)
      public struct Emote: Decodable, Sendable {
        public let id: String
        public let setID: String
        public let ownerID: String
        public let format: [Format]

        enum CodingKeys: String, CodingKey {
          case id, format
          case setID = "emoteSetId"
          case ownerID = "ownerId"
        }

        public enum Format: String, Decodable, Sendable {
          case gif = "animated"
          case png = "static"
        }
      }

      @MemberwiseInit(.public)
      public struct Cheermote: Decodable, Sendable {
        public let prefix: String
        public let tier: Int
        public let bits: Int
      }

      @MemberwiseInit(.public)
      public struct Mention: Decodable, Sendable {
        public let userID: String
        public let userLogin: String
        public let userDisplayName: String

        enum CodingKeys: String, CodingKey {
          case userID = "userId"
          case userLogin
          case userDisplayName = "userName"
        }
      }
    }
  }
}
