import MemberwiseInit

/// An EventSub notification delivered when a user gifts channel subscriptions.
@MemberwiseInit(.public)
public struct ChannelSubscriptionGiftEvent: Event {
  /// The gifter’s identity; `nil` means the gift was anonymous.
  public let gifter: Gifter?

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The number of subscriptions included in this gift.
  public let total: Int
  /// The cumulative contribution total, when provided.
  public let cumulativeTotal: Int?

  /// The subscription tier.
  public let tier: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case total
    case cumulativeTotal
    case tier
    case isAnonymous
  }

  /// Decodes a subscription gift, mapping an anonymous gifter to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
    if isAnonymous == true {
      gifter = nil
    } else {
      let gifterID = try container.decode(String.self, forKey: .userID)
      let gifterLogin = try container.decode(String.self, forKey: .userLogin)
      let gifterDisplayName = try container.decode(String.self, forKey: .userDisplayName)

      gifter = .init(
        userID: gifterID, userLogin: gifterLogin, userDisplayName: gifterDisplayName)
    }

    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)

    total = try container.decode(Int.self, forKey: .total)
    cumulativeTotal = try container.decodeIfPresent(Int.self, forKey: .cumulativeTotal)

    tier = try container.decode(String.self, forKey: .tier)
  }

  /// The account identity of the user who gifted the subscriptions.
  @MemberwiseInit(.public)
  public struct Gifter: Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s login name.
    public let userLogin: String
    /// The user’s display name.
    public let userDisplayName: String
  }
}
