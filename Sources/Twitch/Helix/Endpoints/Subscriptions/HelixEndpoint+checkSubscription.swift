import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Checks whether the authenticated user subscribes to a broadcaster.
  ///
  /// With a user access token, requires `user:read:subscriptions`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#check-user-subscription
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// A user who does not subscribe produces HTTP 404. Executing this endpoint throws
  /// `HelixError.twitchError` for that response; it does not convert HTTP 404 to `nil`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///
  /// - Returns: An endpoint that yields subscription details when executed. The result is
  ///   `nil` only if Twitch returns a successful response with an empty data array.
  public static func checkSubscription(to broadcasterID: String)
    -> HelixEndpoint<Subscription?, Subscription, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "subscriptions/user",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("user_id", try credentials.requireUser().id),
        ]
      },
      makeResponse: { response in
        return response.data.first
      })
  }
}

/// A user’s subscription to a broadcaster, including tier and gift details.
@MemberwiseInit(.public)
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

/// The three paid subscription tiers, encoded as Twitch’s numeric tier strings.
public enum SubscriptionTier: String, Decodable, Sendable {
  /// A Tier 1 subscription. Encoded as `"1000"`.
  case tier1 = "1000"
  /// A Tier 2 subscription. Encoded as `"2000"`.
  case tier2 = "2000"
  /// A Tier 3 subscription. Encoded as `"3000"`.
  case tier3 = "3000"
}

/// The identity of the account that gifted a subscription.
@MemberwiseInit(.public)
public struct SubscriptionGifter: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id, login
    case displayName = "name"
  }
}
