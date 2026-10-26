import MemberwiseInit

/// An EventSub notification delivered when a viewer uses Bits in a channel.
@MemberwiseInit(.public)
public struct ChannelBitsUseEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The number of Bits.
  public let bits: Int
  /// The message content or explanatory text supplied by Twitch, when provided.
  public let message: Message?

  /// Whether the Bits paid for a Cheer or a Power-up, with its associated details.
  public let type: BitsUseType

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case bits
    case message
  }

  /// Decodes Bits usage and its Cheer or Power-up payload.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    userID = try container.decode(String.self, forKey: .userID)
    userLogin = try container.decode(String.self, forKey: .userLogin)
    userDisplayName = try container.decode(String.self, forKey: .userDisplayName)
    bits = try container.decode(Int.self, forKey: .bits)
    message = try container.decodeIfPresent(Message.self, forKey: .message)

    type = try BitsUseType(from: decoder)
  }

  /// A chat message’s full text and ordered content fragments.
  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
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
      /// The text content.
      public let text: String
      /// The category of content represented by this fragment.
      public let type: FragmentType

      enum CodingKeys: String, CodingKey {
        case text, type
      }

      /// Decodes the fragment and its type-specific metadata.
      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        type = try FragmentType(from: decoder)
      }

      /// The content kind of a message fragment and any associated metadata.
      public enum FragmentType: Sendable {
        /// An emote message fragment with its associated metadata.
        case emote(Emote)
        /// A cheermote message fragment with its associated metadata.
        case cheermote(Cheermote)
        /// A text message fragment.
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

      /// Emote metadata for a fragment of the chat message.
      @MemberwiseInit(.public)
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
        /// The identifier of the set.
        public let setID: String
        /// The identifier of the owner.
        public let ownerID: String
        /// The supported image formats.
        public let format: [String]

        enum CodingKeys: String, CodingKey {
          case id
          case setID = "emoteSetId"
          case ownerID = "ownerId"
          case format
        }

        enum Format: String, Decodable, Sendable {
          case gif = "animated"
          case png = "static"
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
}

/// Whether a viewer spent Bits on a Cheer or a Power-up.
public enum BitsUseType: Sendable {
  /// Bits were spent on a Cheer.
  case cheer
  /// Bits purchased a Power-up; includes its type and any emote or message effect.
  case powerUp(PowerUp)

  /// A purchased Power-up’s type and any emote or message-effect metadata.
  @MemberwiseInit(.public)
  public struct PowerUp: Decodable, Sendable {
    /// The Power-up identifier supplied by Twitch.
    public let type: String
    /// The emote details, when provided.
    public let emote: Emote?
    /// The identifier of the message effect, when provided.
    public let messageEffectID: String?

    enum CodingKeys: String, CodingKey {
      case type, emote
      case messageEffectID = "messageEffectId"
    }

    /// Emote metadata for a fragment of the chat message.
    public struct Emote: Decodable, Sendable {
      /// The identifier assigned by Twitch.
      public let id: String
      /// The name supplied by Twitch.
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
