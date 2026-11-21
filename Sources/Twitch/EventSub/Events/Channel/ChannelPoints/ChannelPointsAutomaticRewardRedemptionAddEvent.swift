import Foundation

/// An EventSub notification delivered when a viewer redeems an automatic Channel Points
/// reward.
public struct ChannelPointsAutomaticRewardRedemptionAddEvent: Event {
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

  /// The identifier assigned by Twitch.
  public let id: String
  /// The reward details.
  public let reward: Reward
  /// The message content or explanatory text supplied by Twitch.
  public let message: Message?
  /// The time the reward was redeemed.
  public let redeemedAt: Date

  /// Creates a `ChannelPointsAutomaticRewardRedemptionAddEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    id: String,
    reward: Reward,
    message: Message? = nil,
    redeemedAt: Date
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.id = id
    self.reward = reward
    self.message = message
    self.redeemedAt = redeemedAt
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case id
    case reward
    case message
    case redeemedAt
  }

  /// The automatic reward’s type, Channel Points cost, and any unlocked emote.
  public struct Reward: Decodable, Sendable {
    /// The automatic reward redeemed by the viewer.
    public let type: RewardType
    /// The number of Channel Points.
    public let channelPoints: Int
    /// The emote details, when provided.
    public let emote: Emote?

    /// Creates a `Reward` value.
    public init(
      type: RewardType,
      channelPoints: Int,
      emote: Emote? = nil
    ) {
      self.type = type
      self.channelPoints = channelPoints
      self.emote = emote
    }

    /// Emote metadata included with an automatic reward redemption.
    public struct Emote: Decodable, Sendable {
      /// The identifier assigned by Twitch.
      public let id: String
      /// The human-readable emote token.
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

    /// The built-in Channel Points reward redeemed by the viewer, preserving unfamiliar
    /// values in `rawValue`.
    public struct RewardType: RawRepresentable, Decodable, Sendable, Hashable {
      /// The exact reward type string supplied by Twitch or the caller.
      public let rawValue: String

      /// Creates a reward type from any raw string.
      public init(rawValue: String) { self.rawValue = rawValue }

      /// Decodes a reward type from a single string.
      public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
      }

      /// Allows one message to bypass subscriber-only chat. Encoded as
      /// `"single_message_bypass_sub_mode"`.
      public static let singleMessageBypassSubMode = Self(
        rawValue: "single_message_bypass_sub_mode")
      /// Highlights the redeemed chat message. Encoded as `"send_highlighted_message"`.
      public static let sendHighlightedMessage = Self(rawValue: "send_highlighted_message")
      /// Unlocks a random subscriber emote. Encoded as `"random_sub_emote_unlock"`.
      public static let randomSubEmoteUnlock = Self(rawValue: "random_sub_emote_unlock")
      /// Unlocks the subscriber emote chosen by the viewer. Encoded as
      /// `"chosen_sub_emote_unlock"`.
      public static let chosenSubEmoteUnlock = Self(rawValue: "chosen_sub_emote_unlock")
      /// Unlocks a modified version of a chosen subscriber emote. Encoded as
      /// `"chosen_modified_sub_emote_unlock"`.
      public static let chosenModifiedSubEmoteUnlock = Self(
        rawValue: "chosen_modified_sub_emote_unlock")
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

    /// A run of message text with its content type and any associated metadata.
    public struct Fragment: Decodable, Sendable {
      /// The category of content represented by this fragment.
      public let type: FragmentType
      /// The text content.
      public let text: String
      /// The emote details, when provided.
      public let emote: Emote?

      /// Creates a `Fragment` value.
      public init(
        type: FragmentType,
        text: String,
        emote: Emote? = nil
      ) {
        self.type = type
        self.text = text
        self.emote = emote
      }

      enum CodingKeys: String, CodingKey {
        case type
        case text
        case emote
      }

      /// Decodes the fragment and its type-specific metadata.
      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        emote = try container.decodeIfPresent(Emote.self, forKey: .emote)
        type = try container.decode(FragmentType.self, forKey: .type)
      }

      /// The content kind of a message fragment, preserving unfamiliar values in
      /// `rawValue`.
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
      }

      /// Emote metadata for a fragment of the chat message.
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String

        /// Creates an `Emote` value.
        public init(
          id: String
        ) {
          self.id = id
        }
      }
    }
  }
}
