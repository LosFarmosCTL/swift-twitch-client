/// An EventSub notification delivered when a user sends a channel chat message.
public struct ChannelChatMessageEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the chatter.
  public let chatterID: String
  /// The login name of the chatter.
  public let chatterLogin: String
  /// The display name of the chatter.
  public let chatterDisplayName: String

  /// The identifier of the message.
  public let messageID: String
  /// The structured message text and ordered content fragments.
  public let message: Message

  /// The category of chat message.
  public let messageType: MessageType
  /// The color reported by Twitch, when provided.
  public let color: String?
  /// The chat badges.
  public let badges: [Badge]
  /// The reply and thread metadata, when provided.
  public let reply: Reply?

  /// The Cheer details, when provided.
  public let cheer: Cheer?

  /// The identifier of the channel points custom reward, when provided.
  public let channelPointsCustomRewardID: String?

  /// The Twitch user ID of the source broadcaster, when provided.
  public let sourceBroadcasterID: String?
  /// The login name of the source broadcaster, when provided.
  public let sourceBroadcasterLogin: String?
  /// The display name of the source broadcaster, when provided.
  public let sourceBroadcasterDisplayName: String?
  /// The identifier of the source message, when provided.
  public let sourceMessageID: String?
  /// The badges from the source channel, when provided.
  public let sourceBadges: [Badge]?
  /// Whether the message is restricted to the source channel in shared chat, when
  /// provided.
  public let isSourceOnly: Bool?

  /// Creates a `ChannelChatMessageEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    chatterID: String,
    chatterLogin: String,
    chatterDisplayName: String,
    messageID: String,
    message: Message,
    messageType: MessageType,
    color: String? = nil,
    badges: [Badge] = [],
    reply: Reply? = nil,
    cheer: Cheer? = nil,
    channelPointsCustomRewardID: String? = nil,
    sourceBroadcasterID: String? = nil,
    sourceBroadcasterLogin: String? = nil,
    sourceBroadcasterDisplayName: String? = nil,
    sourceMessageID: String? = nil,
    sourceBadges: [Badge]? = nil,
    isSourceOnly: Bool? = nil
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.chatterID = chatterID
    self.chatterLogin = chatterLogin
    self.chatterDisplayName = chatterDisplayName
    self.messageID = messageID
    self.message = message
    self.messageType = messageType
    self.color = color
    self.badges = badges
    self.reply = reply
    self.cheer = cheer
    self.channelPointsCustomRewardID = channelPointsCustomRewardID
    self.sourceBroadcasterID = sourceBroadcasterID
    self.sourceBroadcasterLogin = sourceBroadcasterLogin
    self.sourceBroadcasterDisplayName = sourceBroadcasterDisplayName
    self.sourceMessageID = sourceMessageID
    self.sourceBadges = sourceBadges
    self.isSourceOnly = isSourceOnly
  }

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
}

extension ChannelChatMessageEvent {
  /// A Twitch message classification. Unrecognized strings are preserved in `rawValue`.
  public struct MessageType: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact classification string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a message classification from any string.
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    /// Decodes a message classification from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// An ordinary text chat message. Encoded as `"text"`.
    public static let text = Self(rawValue: "text")
    /// A message highlighted through a Channel Points redemption. Encoded as
    /// `"channel_points_highlighted"`.
    public static let channelPointsHighlighted = Self(
      rawValue: "channel_points_highlighted")
    /// A message sent using a Channel Points subscriber-only bypass. Encoded as
    /// `"channel_points_sub_only"`.
    public static let channelPointsSubOnly = Self(rawValue: "channel_points_sub_only")
    /// A user introduction message. Encoded as `"user_intro"`.
    public static let userIntro = Self(rawValue: "user_intro")
    /// A message using a Bits Power-up effect. Encoded as `"power_ups_message_effect"`.
    public static let powerUpsMessageEffect = Self(rawValue: "power_ups_message_effect")
    /// A message using a Bits Power-up enlarged emote. Encoded as
    /// `"power_ups_gigantified_emote"`.
    public static let powerUpsGigantifiedEmote = Self(
      rawValue: "power_ups_gigantified_emote")
  }

  /// A badge’s set, version, and additional information for the message author.
  public struct Badge: Decodable, Sendable {
    /// The identifier of the set.
    public let setID: String
    /// The identifier assigned by Twitch.
    public let id: String
    /// Additional badge information; subscriber badges use this for the subscribed
    /// months.
    public let info: String

    /// Creates a `Badge` value.
    public init(
      setID: String,
      id: String,
      info: String
    ) {
      self.setID = setID
      self.id = id
      self.info = info
    }

    enum CodingKeys: String, CodingKey {
      case setID = "setId"
      case id, info
    }
  }

  /// The parent message and root thread of a chat reply, including their authors.
  public struct Reply: Decodable, Sendable {
    /// The identifier of the parent.
    public let parentID: String
    /// The text of the message being replied to.
    public let parentBody: String

    /// The Twitch user ID of the author of the parent message.
    public let parentUserID: String
    /// The login name of the author of the parent message.
    public let parentUserLogin: String
    /// The display name of the author of the parent message.
    public let parentUserDisplayName: String

    /// The identifier of the thread.
    public let threadID: String
    /// The Twitch user ID of the author of the thread’s root message.
    public let threadUserID: String
    /// The login name of the author of the thread’s root message.
    public let threadUserLogin: String
    /// The display name of the author of the thread’s root message.
    public let threadUserDisplayName: String

    /// Creates a `Reply` value.
    public init(
      parentID: String,
      parentBody: String,
      parentUserID: String,
      parentUserLogin: String,
      parentUserDisplayName: String,
      threadID: String,
      threadUserID: String,
      threadUserLogin: String,
      threadUserDisplayName: String
    ) {
      self.parentID = parentID
      self.parentBody = parentBody
      self.parentUserID = parentUserID
      self.parentUserLogin = parentUserLogin
      self.parentUserDisplayName = parentUserDisplayName
      self.threadID = threadID
      self.threadUserID = threadUserID
      self.threadUserLogin = threadUserLogin
      self.threadUserDisplayName = threadUserDisplayName
    }

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

  /// The total Bits included in a chat message’s Cheer.
  public struct Cheer: Decodable, Sendable {
    /// The number of Bits.
    public let bits: Int

    /// Creates a `Cheer` value.
    public init(
      bits: Int
    ) {
      self.bits = bits
    }
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
      /// The category of content represented by this fragment.
      public let type: FragmentType
      /// The text content.
      public let text: String

      /// Creates a `Fragment` value.
      public init(
        type: FragmentType,
        text: String
      ) {
        self.type = type
        self.text = text
      }

      enum CodingKeys: String, CodingKey {
        case type
        case text
      }

      /// Decodes the fragment and its type-specific metadata.
      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.text = try container.decode(String.self, forKey: .text)
        self.type = try FragmentType(from: decoder)
      }

      /// The content kind of a message fragment and any associated metadata.
      public enum FragmentType: Sendable {
        /// A text message fragment.
        case text
        /// An emote message fragment with its associated metadata.
        case emote(Emote)
        /// A cheermote message fragment with its associated metadata.
        case cheermote(Cheermote)
        /// A mention message fragment with its associated metadata.
        case mention(Mention)
        /// A GIF message fragment with its associated metadata.
        case gif(GIF)
        /// An unfamiliar fragment kind. The fragment's text remains available.
        case unknown(String)

        enum CodingKeys: String, CodingKey {
          case type
          case emote
          case cheermote
          case mention
          case gif
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let rawType = try container.decode(String.self, forKey: .type)
          guard let type = FragmentType(rawValue: rawType) else {
            self = .unknown(rawType)
            return
          }

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

        private enum FragmentType: String {
          case text, emote, cheermote, mention, gif
        }
      }

      /// The identifier and media URL of a GIF embedded in a chat message.
      public struct GIF: Decodable, Sendable {
        /// The identifier of the GIF.
        public let gifID: String
        /// The media URL of the GIF.
        public let url: String

        /// Creates a `GIF` value.
        public init(
          gifID: String,
          url: String
        ) {
          self.gifID = gifID
          self.url = url
        }

        enum CodingKeys: String, CodingKey {
          case gifID = "gifId"
          case url
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
        public let format: [Format]

        /// Creates an `Emote` value.
        public init(
          id: String,
          setID: String,
          ownerID: String,
          format: [Format] = []
        ) {
          self.id = id
          self.setID = setID
          self.ownerID = ownerID
          self.format = format
        }

        enum CodingKeys: String, CodingKey {
          case id, format
          case setID = "emoteSetId"
          case ownerID = "ownerId"
        }

        /// The animated or static image variant available for an emote, preserving
        /// unfamiliar values in `rawValue`.
        public struct Format: RawRepresentable, Decodable, Sendable, Hashable {
          /// The exact image format string supplied by Twitch or the caller.
          public let rawValue: String

          /// Creates an emote format from any raw string.
          public init(rawValue: String) { self.rawValue = rawValue }

          /// Decodes an emote format from a single string.
          public init(from decoder: Decoder) throws {
            self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
          }

          /// An animated image format. Encoded as `"animated"`.
          public static let gif = Self(rawValue: "animated")
          /// A static image format. Encoded as `"static"`.
          public static let png = Self(rawValue: "static")
        }
      }

      /// A Cheermote’s prefix, Bits amount, and contribution tier.
      public struct Cheermote: Decodable, Sendable {
        /// The prefix used to identify the Cheermote in chat.
        public let prefix: String
        /// The Cheermote tier.
        public let tier: Int
        /// The number of Bits.
        public let bits: Int

        /// Creates a `Cheermote` value.
        public init(
          prefix: String,
          tier: Int,
          bits: Int
        ) {
          self.prefix = prefix
          self.tier = tier
          self.bits = bits
        }
      }

      /// The account identity of a user mentioned in a chat message.
      public struct Mention: Decodable, Sendable {
        /// The Twitch user ID.
        public let userID: String
        /// The user’s login name.
        public let userLogin: String
        /// The user’s display name.
        public let userDisplayName: String

        /// Creates a `Mention` value.
        public init(
          userID: String,
          userLogin: String,
          userDisplayName: String
        ) {
          self.userID = userID
          self.userLogin = userLogin
          self.userDisplayName = userDisplayName
        }

        enum CodingKeys: String, CodingKey {
          case userID = "userId"
          case userLogin
          case userDisplayName = "userName"
        }
      }
    }
  }
}
