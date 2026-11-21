import Foundation

/// An EventSub notification delivered when a subscriber shares a resubscription message.
public struct ChannelSubscriptionMessageEvent: Event {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The subscription tier.
  public let tier: SubscriptionTier
  /// The number of months included in the subscription.
  public let durationMonths: Int
  /// The total number of subscribed months.
  public let cumulativeMonths: Int
  /// The number of consecutive subscribed months, when provided.
  public let streakMonths: Int?

  /// The message content or explanatory text supplied by Twitch.
  public let message: Message

  /// Creates a `ChannelSubscriptionMessageEvent` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    tier: SubscriptionTier,
    durationMonths: Int,
    cumulativeMonths: Int,
    streakMonths: Int? = nil,
    message: Message
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.tier = tier
    self.durationMonths = durationMonths
    self.cumulativeMonths = cumulativeMonths
    self.streakMonths = streakMonths
    self.message = message
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case tier
    case cumulativeMonths
    case streakMonths
    case durationMonths
    case message
  }

  /// A resubscription message and the emote ranges needed to render it.
  public struct Message: Decodable, Sendable {
    /// The text content.
    public let text: String
    /// The emote metadata.
    public let emotes: [Emote]

    /// Creates a `Message` value.
    public init(
      text: String,
      emotes: [Emote] = []
    ) {
      self.text = text
      self.emotes = emotes
    }

    enum CodingKeys: String, CodingKey {
      case text, emotes
    }

    /// Decodes a resubscription message, treating a `null` `emotes` field as an empty list.
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      text = try container.decode(String.self, forKey: .text)
      emotes = try container.decodeIfPresent([Emote].self, forKey: .emotes) ?? []
    }

    /// Emote metadata for a fragment of the chat message.
    public struct Emote: Decodable, Sendable {
      /// The beginning of the matched text range.
      public let begin: Int
      /// The end of the matched text range.
      public let end: Int
      /// The identifier assigned by Twitch.
      public let id: String

      /// Creates an `Emote` value.
      public init(
        begin: Int,
        end: Int,
        id: String
      ) {
        self.begin = begin
        self.end = end
        self.id = id
      }
    }
  }
}
