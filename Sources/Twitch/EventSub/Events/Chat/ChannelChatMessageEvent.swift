import MemberwiseInit

/// An EventSub notification delivered when a user sends a channel chat message.
@MemberwiseInit(.public)
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
  /// The message content or explanatory text supplied by Twitch.
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

  /// Whether a chat message is ordinary text, an introduction, or a rewarded message.
  public enum MessageType: String, Decodable, Sendable {
    /// An ordinary text chat message. Encoded as `"text"`.
    case text = "text"
    /// A message highlighted through a Channel Points redemption. Encoded as
    /// `"channel_points_highlighted"`.
    case channelPointsHighlighted = "channel_points_highlighted"
    /// A message sent using a Channel Points subscriber-only bypass. Encoded as
    /// `"channel_points_sub_only"`.
    case channelPointsSubOnly = "channel_points_sub_only"
    /// A user introduction message. Encoded as `"user_intro"`.
    case userIntro = "user_intro"
    /// A message using a Bits Power-up effect. Encoded as `"power_ups_message_effect"`.
    case powerUpsMessageEffect = "power_ups_message_effect"
    /// A message using a Bits Power-up enlarged emote. Encoded as
    /// `"power_ups_gigantified_emote"`.
    case powerUpsGigantifiedEmote = "power_ups_gigantified_emote"
  }

  /// A badge’s set, version, and additional information for the message author.
  @MemberwiseInit(.public)
  public struct Badge: Decodable, Sendable {
    /// The identifier of the set.
    public let setID: String
    /// The identifier assigned by Twitch.
    public let id: String
    /// Additional badge information; subscriber badges use this for the subscribed
    /// months.
    public let info: String

    enum CodingKeys: String, CodingKey {
      case setID = "setId"
      case id, info
    }
  }

  /// The parent message and root thread of a chat reply, including their authors.
  @MemberwiseInit(.public)
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
  @MemberwiseInit(.public)
  public struct Cheer: Decodable, Sendable {
    /// The number of Bits.
    public let bits: Int
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
      /// The category of content represented by this fragment.
      public let type: FragmentType
      /// The text content.
      public let text: String

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
        /// An animated image format.
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

      /// The identifier and media URL of a GIF embedded in a chat message.
      @MemberwiseInit(.public)
      public struct GIF: Decodable, Sendable {
        /// The identifier of the gif.
        public let gifID: String
        /// The URL associated with this resource.
        public let url: String

        enum CodingKeys: String, CodingKey {
          case gifID = "gifId"
          case url
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
        public let format: [Format]

        enum CodingKeys: String, CodingKey {
          case id, format
          case setID = "emoteSetId"
          case ownerID = "ownerId"
        }

        /// The animated or static image variants available for an emote.
        public enum Format: String, Decodable, Sendable {
          /// An animated image format. Encoded as `"animated"`.
          case gif = "animated"
          /// A static image format. Encoded as `"static"`.
          case png = "static"
        }
      }

      /// A Cheermote’s prefix, Bits amount, and contribution tier.
      @MemberwiseInit(.public)
      public struct Cheermote: Decodable, Sendable {
        /// The prefix used to identify the Cheermote in chat.
        public let prefix: String
        /// The Cheermote tier.
        public let tier: Int
        /// The number of Bits.
        public let bits: Int
      }

      /// The account identity of a user mentioned in a chat message.
      @MemberwiseInit(.public)
      public struct Mention: Decodable, Sendable {
        /// The Twitch user ID.
        public let userID: String
        /// The user’s login name.
        public let userLogin: String
        /// The user’s display name.
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
