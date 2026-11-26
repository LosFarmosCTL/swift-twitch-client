/// The text and fragments of a message held for moderation.
public struct AutoModMessage: Decodable, Sendable {
  /// The text content.
  public let text: String
  /// The ordered message fragments.
  public let fragments: [Fragment]

  /// Creates an `AutoModMessage` value.
  public init(
    text: String,
    fragments: [Fragment] = []
  ) {
    self.text = text
    self.fragments = fragments
  }

  enum CodingKeys: String, CodingKey {
    case text
    case fragments
  }

  /// A run of message text with its content type and any associated metadata.
  public struct Fragment: Decodable, Sendable {
    /// The content kind. AutoMod documents text, emote, and cheermote fragments.
    public let type: FragmentType
    /// The text content.
    public let text: String
    /// The emote details, when provided.
    public let emote: Emote?
    /// The Cheermote details, when provided.
    public let cheermote: Cheermote?
    /// The mentioned account, when supplied.
    public let mention: ChannelChatMessageEvent.Message.Fragment.Mention?
    /// The embedded GIF, when supplied.
    public let gif: ChannelChatMessageEvent.Message.Fragment.GIF?

    /// Creates a `Fragment` value.
    public init(
      type: FragmentType,
      text: String,
      emote: Emote? = nil,
      cheermote: Cheermote? = nil,
      mention: ChannelChatMessageEvent.Message.Fragment.Mention? = nil,
      gif: ChannelChatMessageEvent.Message.Fragment.GIF? = nil
    ) {
      self.type = type
      self.text = text
      self.emote = emote
      self.cheermote = cheermote
      self.mention = mention
      self.gif = gif
    }

    enum CodingKeys: String, CodingKey {
      case type
      case text
      case emote
      case cheermote
      case mention
      case gif
    }

    /// Decodes a fragment, inferring its type from metadata when Twitch omits the type.
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      text = try container.decode(String.self, forKey: .text)
      emote = try container.decodeIfPresent(Emote.self, forKey: .emote)
      cheermote = try container.decodeIfPresent(Cheermote.self, forKey: .cheermote)
      mention = try container.decodeIfPresent(
        ChannelChatMessageEvent.Message.Fragment.Mention.self, forKey: .mention)
      gif = try container.decodeIfPresent(
        ChannelChatMessageEvent.Message.Fragment.GIF.self, forKey: .gif)

      if let type = try container.decodeIfPresent(FragmentType.self, forKey: .type) {
        self.type = type
      } else if emote != nil {
        self.type = .emote
      } else if cheermote != nil {
        self.type = .cheermote
      } else if mention != nil {
        self.type = .mention
      } else if gif != nil {
        self.type = .gif
      } else {
        self.type = .text
      }
    }

    /// The content kind of a message fragment, preserving unfamiliar values in `rawValue`.
    public struct FragmentType: RawRepresentable, Decodable, Sendable, Hashable {
      /// The exact fragment type string supplied by Twitch or the caller.
      public let rawValue: String

      /// Creates a fragment type from any raw string.
      public init(rawValue: String) { self.rawValue = rawValue }

      /// Decodes a fragment type from a single string.
      public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
      }

      /// A text message fragment.
      public static let text = Self(rawValue: "text")
      /// An emote message fragment.
      public static let emote = Self(rawValue: "emote")
      /// A cheermote message fragment.
      public static let cheermote = Self(rawValue: "cheermote")
      /// A user mention fragment.
      public static let mention = Self(rawValue: "mention")
      /// A GIF fragment.
      public static let gif = Self(rawValue: "gif")
    }

    /// Emote metadata for a fragment of the chat message.
    public struct Emote: Decodable, Sendable {
      /// The identifier assigned by Twitch.
      public let id: String
      /// The identifier of the set.
      public let setID: String

      /// Creates an `Emote` value.
      public init(
        id: String,
        setID: String
      ) {
        self.id = id
        self.setID = setID
      }

      enum CodingKeys: String, CodingKey {
        case id
        case setID = "emoteSetId"
      }
    }

    /// A Cheermote’s prefix, Bits amount, and contribution tier.
    public struct Cheermote: Decodable, Sendable {
      /// The prefix used to identify the Cheermote in chat.
      public let prefix: String
      /// The number of Bits.
      public let bits: Int
      /// The minimum Bits required for the tier reached by this cheer.
      public let tier: Int

      /// Creates a `Cheermote` value.
      public init(
        prefix: String,
        bits: Int,
        tier: Int
      ) {
        self.prefix = prefix
        self.bits = bits
        self.tier = tier
      }
    }
  }
}
