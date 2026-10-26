import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a subscriber shares a resubscription message.
@MemberwiseInit(.public)
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
  public let tier: String
  /// The number of months included in the subscription.
  public let durationMonths: Int
  /// The total number of subscribed months.
  public let cumulativeMonths: Int
  /// The number of consecutive subscribed months, when provided.
  public let streakMonths: Int?

  /// The message content or explanatory text supplied by Twitch.
  public let message: Message

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
  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
    /// The text content.
    public let text: String
    /// The emote metadata.
    public let emotes: [Emote]

    /// Emote metadata for a fragment of the chat message.
    @MemberwiseInit(.public)
    public struct Emote: Decodable, Sendable {
      /// The beginning of the matched text range.
      public let begin: Int
      /// The end of the matched text range.
      public let end: Int
      /// The identifier assigned by Twitch.
      public let id: String
    }
  }
}
