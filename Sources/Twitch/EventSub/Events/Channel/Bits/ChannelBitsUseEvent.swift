public struct ChannelBitsUseEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let bits: Int
  public let message: Message?

  public let type: BitsUseType

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case userID = "userId"
    case userLogin, userName

    case bits, message
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userName = try container.decode(String.self, forKey: .userName)
    bits = try container.decode(Int.self, forKey: .bits)
    message = try container.decodeIfPresent(Message.self, forKey: .message)

    type = try BitsUseType(from: decoder)
  }

  public struct Message: Decodable, Sendable {
    public let text: String
    public let fragments: [Fragment]

    enum CodingKeys: String, CodingKey {
      case text
      case fragments
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
        public let ownerID: String
        public let format: [String]

        enum CodingKeys: String, CodingKey {
          case id
          case emoteSetID = "emoteSetId"
          case ownerID = "ownerId"
          case format
        }

        enum Format: String, Decodable, Sendable {
          case gif = "animated"
          case png = "static"
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

public enum BitsUseType: Sendable {
  case cheer
  case powerUp(PowerUp)

  public struct PowerUp: Decodable, Sendable {
    public let type: String
    public let emote: Emote?
    public let messageEffectID: String?

    enum CodingKeys: String, CodingKey {
      case type, emote
      case messageEffectID = "messageEffectId"
    }

    public struct Emote: Decodable, Sendable {
      public let id: String
      public let name: String
    }
  }

  enum CodingKeys: String, CodingKey {
    case type, cheer, powerUp
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let type = try container.decode(UseType.self, forKey: .type)
    switch type {
    case .cheer:
      self = .cheer
    case .powerUp:
      let powerUp = try container.decode(PowerUp.self, forKey: .powerUp)
      self = .powerUp(powerUp)
    }
  }

  private enum UseType: String, Decodable, Sendable {
    case cheer = "cheer"
    case powerUp = "power_up"
  }
}
