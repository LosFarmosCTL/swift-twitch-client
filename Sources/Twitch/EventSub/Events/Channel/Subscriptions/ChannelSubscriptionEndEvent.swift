import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelSubscriptionEndEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let tier: SubscriptionTier
  public let isGift: Bool

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
