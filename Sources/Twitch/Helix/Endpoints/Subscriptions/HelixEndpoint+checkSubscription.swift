import Foundation

extension HelixEndpoint {
  /// Checks whether a user subscribes to a broadcaster.
  ///
  /// With a user access token, requires `user:read:subscriptions`. App tokens require
  /// the user’s prior authorization with that scope and an explicit `userID`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/subscriptions/#check-user-subscription
  /// ) for request limits and account requirements.
  ///
  /// With user tokens, `userID` defaults to the token’s user and must match it.
  ///
  /// A user who does not subscribe produces HTTP 404. Executing this endpoint throws
  /// `HelixError.twitchError` for that response; it does not convert HTTP 404 to `nil`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - userID: Required for app tokens; otherwise defaults to the token’s user.
  ///
  /// - Returns: An endpoint that yields subscription details when executed. The result is
  ///   `nil` only if Twitch returns a successful response with an empty data array.
  public static func checkSubscription(to broadcasterID: String, userID: String? = nil)
    -> HelixEndpoint<Subscription?>
  {
    .init(
      method: "GET", path: "subscriptions/user",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "user_id",
            try credentials.resolveUserID(
              userID, parameter: "user_id", matchingToken: true)
          ),
        ]
      },
      responseType: Subscription.self,
      makeResponse: { response in
        return response.data.first
      })
  }
}

/// A user’s subscription to a broadcaster, including tier and gift details.
public struct Subscription: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The gifter’s identity; `nil` means the subscription was not gifted.
  public let gifter: SubscriptionGifter?

  /// The subscription tier.
  public let tier: SubscriptionTier

  /// Creates a `Subscription` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    gifter: SubscriptionGifter? = nil,
    tier: SubscriptionTier
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.gifter = gifter
    self.tier = tier
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case isGift
    case gifterID = "gifterId"
    case gifterLogin
    case gifterDisplayName = "gifterName"
    case tier
  }

  /// Decodes a subscription, including gifter details only for gifted subscriptions.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    self.broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)

    if try container.decode(Bool.self, forKey: .isGift) {
      self.gifter = .init(
        id: try container.decode(String.self, forKey: .gifterID),
        login: try container.decode(String.self, forKey: .gifterLogin),
        displayName: try container.decode(String.self, forKey: .gifterDisplayName))
    } else {
      self.gifter = nil
    }

    self.tier = try container.decode(SubscriptionTier.self, forKey: .tier)
  }
}

/// The paid subscription tiers, encoded as Twitch’s numeric tier strings, preserving
/// unfamiliar values in `rawValue`.
public struct SubscriptionTier: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact subscription tier string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a subscription tier from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a subscription tier from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// A Tier 1 subscription. Encoded as `"1000"`.
  public static let tier1 = Self(rawValue: "1000")
  /// A Tier 2 subscription. Encoded as `"2000"`.
  public static let tier2 = Self(rawValue: "2000")
  /// A Tier 3 subscription. Encoded as `"3000"`.
  public static let tier3 = Self(rawValue: "3000")
}

/// The identity of the account that gifted a subscription.
public struct SubscriptionGifter: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  /// Creates a `SubscriptionGifter` value.
  public init(
    id: String,
    login: String,
    displayName: String
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
  }

  enum CodingKeys: String, CodingKey {
    case id, login
    case displayName = "name"
  }
}
