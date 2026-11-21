/// An EventSub notification delivered when a viewer uses Bits in a channel.
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

  /// What the Bits paid for, with associated details.
  public let type: BitsUseType

  /// Creates a `ChannelBitsUseEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    bits: Int,
    message: Message? = nil,
    type: BitsUseType
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.bits = bits
    self.message = message
    self.type = type
  }

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

  /// Decodes Bits usage and its type-specific payload.
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
  public struct Message: Decodable, Sendable {
    /// The text content.
    public let text: String
    /// The ordered message fragments.
    public let fragments: [Fragment]

    /// Creates a `Message` value.
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
      /// The text content.
      public let text: String
      /// The category of content represented by this fragment.
      public let type: FragmentType

      /// Creates a `Fragment` value.
      public init(
        text: String,
        type: FragmentType
      ) {
        self.text = text
        self.type = type
      }

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
        /// An unfamiliar fragment kind. The fragment's text remains available.
        case unknown(String)

        enum CodingKeys: String, CodingKey {
          case type, emote, cheermote
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let rawType = try container.decode(String.self, forKey: .type)
          guard let type = FragmentType(rawValue: rawType) else {
            self = .unknown(rawType)
            return
          }

          switch type {
          case .emote:
            self = .emote(try container.decode(Emote.self, forKey: .emote))
          case .cheermote:
            self = .cheermote(try container.decode(Cheermote.self, forKey: .cheermote))
          case .text:
            self = .text
          }
        }

        private enum FragmentType: String {
          case emote, cheermote, text
        }
      }

      /// Emote metadata for a fragment of the chat message.
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
        /// The identifier of the set.
        public let setID: String
        /// The identifier of the owner.
        public let ownerID: String
        /// The supported image formats.
        public let format: [ChannelChatMessageEvent.Message.Fragment.Emote.Format]

        /// Creates an `Emote` value.
        public init(
          id: String,
          setID: String,
          ownerID: String,
          format: [ChannelChatMessageEvent.Message.Fragment.Emote.Format] = []
        ) {
          self.id = id
          self.setID = setID
          self.ownerID = ownerID
          self.format = format
        }

        enum CodingKeys: String, CodingKey {
          case id
          case setID = "emoteSetId"
          case ownerID = "ownerId"
          case format
        }
      }

      /// A Cheermote’s prefix, Bits amount, and contribution tier.
      public struct Cheermote: Decodable, Sendable {
        /// The prefix used to identify the Cheermote in chat.
        public let prefix: String
        /// The number of Bits.
        public let bits: Int
        /// The Cheermote tier.
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
}

extension ChannelBitsUseEvent {
  /// Whether a viewer spent Bits on a Cheer or a Power-up.
  public enum BitsUseType: Sendable {
    /// Bits were spent on a Cheer.
    case cheer
    /// Bits purchased a Power-up; includes its type and any emote or message effect.
    case powerUp(PowerUp)
    /// Bits purchased a broadcaster-defined Power-up.
    case customPowerUp(CustomPowerUp)
    /// An unfamiliar Bits use type, preserved as sent by Twitch.
    case unknown(String)

    /// The identity and display title included with a custom Power-up purchase.
    public struct CustomPowerUp: Decodable, Sendable {
      /// The title shown to viewers.
      public let title: String
      /// The identifier of the custom Power-up reward.
      public let rewardID: String

      /// Creates a `CustomPowerUp` value.
      public init(
        title: String,
        rewardID: String
      ) {
        self.title = title
        self.rewardID = rewardID
      }

      enum CodingKeys: String, CodingKey {
        case title
        case rewardID = "rewardId"
      }
    }

    /// A purchased Power-up’s type and any emote or message-effect metadata.
    public struct PowerUp: Decodable, Sendable {
      /// The Power-up identifier supplied by Twitch.
      public let type: String
      /// The emote details, when provided.
      public let emote: Emote?
      /// The identifier of the message effect, when provided.
      public let messageEffectID: String?

      /// Creates a `PowerUp` value.
      public init(
        type: String,
        emote: Emote? = nil,
        messageEffectID: String? = nil
      ) {
        self.type = type
        self.emote = emote
        self.messageEffectID = messageEffectID
      }

      enum CodingKeys: String, CodingKey {
        case type, emote
        case messageEffectID = "messageEffectId"
      }

      /// Emote metadata included with a Power-up purchase.
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
        /// The name supplied by Twitch.
        public let name: String

        /// Creates an `Emote` value.
        public init(
          id: String,
          name: String
        ) {
          self.id = id
          self.name = name
        }
      }
    }

    enum CodingKeys: String, CodingKey {
      case type, cheer, powerUp, customPowerUp
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let type = try container.decode(String.self, forKey: .type)
      switch type {
      case "cheer":
        self = .cheer
      case "power_up":
        let powerUp = try container.decode(PowerUp.self, forKey: .powerUp)
        self = .powerUp(powerUp)
      case "custom_power_up":
        self = .customPowerUp(try container.decode(CustomPowerUp.self, forKey: .customPowerUp))
      default:
        self = .unknown(type)
      }
    }
  }
}
