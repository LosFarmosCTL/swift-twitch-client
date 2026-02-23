public struct AutomodMessage: Decodable, Sendable {
  public let text: String
  public let fragments: [Fragment]

  enum CodingKeys: String, CodingKey {
    case text
    case fragments
  }

  public struct Fragment: Decodable, Sendable {
    public let type: FragmentType
    public let text: String
    public let emote: Emote?
    public let cheermote: Cheermote?

    enum CodingKeys: String, CodingKey {
      case type
      case text
      case emote
      case cheermote
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      text = try container.decode(String.self, forKey: .text)
      emote = try container.decodeIfPresent(Emote.self, forKey: .emote)
      cheermote = try container.decodeIfPresent(Cheermote.self, forKey: .cheermote)

      if let type = try container.decodeIfPresent(FragmentType.self, forKey: .type) {
        self.type = type
      } else if emote != nil {
        self.type = .emote
      } else if cheermote != nil {
        self.type = .cheermote
      } else {
        self.type = .text
      }
    }

    public enum FragmentType: String, Decodable, Sendable {
      case text
      case emote
      case cheermote
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
