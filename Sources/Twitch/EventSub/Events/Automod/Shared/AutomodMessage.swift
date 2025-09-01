public struct AutomodMessage: Decodable, Sendable {
  public let text: String
  public let fragments: [Fragment]

  enum CodingKeys: String, CodingKey {
    case text
    case fragments
  }

  public struct Fragment: Decodable, Sendable {
    public let text: String
    public let emote: Emote?
    public let cheermote: Cheermote?

    enum CodingKeys: String, CodingKey {
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
