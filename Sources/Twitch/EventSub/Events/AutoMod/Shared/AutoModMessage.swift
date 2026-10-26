import MemberwiseInit

/// The text and fragments of a message held for moderation.
@MemberwiseInit(.public)
public struct AutoModMessage: Decodable, Sendable {
  /// The text content.
  public let text: String
  /// The ordered message fragments.
  public let fragments: [Fragment]

  enum CodingKeys: String, CodingKey {
    case text
    case fragments
  }

  /// A run of message text with its content type and any associated metadata.
  @MemberwiseInit(.public)
  public struct Fragment: Decodable, Sendable {
    /// The category of content represented by this fragment.
    public let type: FragmentType
    /// The text content.
    public let text: String
    /// The emote details, when provided.
    public let emote: Emote?
    /// The Cheermote details, when provided.
    public let cheermote: Cheermote?

    enum CodingKeys: String, CodingKey {
      case type
      case text
      case emote
      case cheermote
    }

    /// Decodes a fragment, inferring its type from emote or Cheermote metadata when
    /// Twitch omits the type.
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

    /// The content kind of a message fragment and any associated metadata.
    public enum FragmentType: String, Decodable, Sendable {
      /// A text message fragment.
      case text
      /// An emote message fragment.
      case emote
      /// A cheermote message fragment.
      case cheermote
    }

    /// Emote metadata for a fragment of the chat message.
    @MemberwiseInit(.public)
    public struct Emote: Decodable, Sendable {
      /// The identifier assigned by Twitch.
      public let id: String
      /// The identifier of the set.
      public let setID: String

      enum CodingKeys: String, CodingKey {
        case id
        case setID = "emoteSetId"
      }
    }

    /// A Cheermote’s prefix, Bits amount, and contribution tier.
    @MemberwiseInit(.public)
    public struct Cheermote: Decodable, Sendable {
      /// The prefix used to identify the Cheermote in chat.
      public let prefix: String
      /// The number of Bits.
      public let bits: Int
      /// The Cheermote tier.
      public let tier: Int
    }
  }
}
