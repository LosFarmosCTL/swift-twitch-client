/// An EventSub notification delivered when a channel subscription expires.
public struct ChannelSubscriptionEndEvent: Event {
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
  /// Whether the subscription was gifted.
  public let isGift: Bool

  /// Creates a `ChannelSubscriptionEndEvent` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    tier: SubscriptionTier,
    isGift: Bool
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.tier = tier
    self.isGift = isGift
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case tier
    case isGift
  }
}
