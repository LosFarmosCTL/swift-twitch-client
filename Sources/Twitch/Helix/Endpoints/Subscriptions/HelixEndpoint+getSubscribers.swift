import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s subscriptions and subscription points.
  ///
  /// With a user access token, requires `channel:read:subscriptions`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-broadcaster-subscriptions
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  public static func getSubscribers(
    userIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<SubscribersResponse, Subscriber, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "subscriptions",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
          ("before", beforeCursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        let total = try $0.require(\.total)
        let points = try $0.require(\.points)

        return SubscribersResponse(
          subscribers: $0.data,
          total: total,
          points: points,
          cursor: $0.pagination?.cursor)
      })
  }
}

/// A page of channel subscribers, subscription totals, and the next cursor.
public struct SubscribersResponse: Sendable {
  /// The channel subscribers.
  public let subscribers: [Subscriber]

  /// The number of subscriptions matching the request across all pages.
  public let total: Int
  /// The total subscription points reported by Twitch.
  public let points: Int

  /// The pagination cursor to pass when requesting another page.
  public let cursor: String?
}

/// A channel subscriber’s account, tier, and gift metadata.
@MemberwiseInit(.public)
public struct Subscriber: Decodable, Sendable {
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

  /// The gifter’s identity; `nil` means the subscription was not gifted.
  public let gifter: SubscriptionGifter?

  /// The subscription plan name.
  public let planName: String
  /// The subscription tier.
  public let tier: SubscriptionTier

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case isGift
    case gifterID = "gifterId"
    case gifterLogin
    case gifterDisplayName = "gifterName"
    case planName
    case tier
  }

  /// Decodes a subscriber, including gifter details only for gifted subscriptions.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.userID = try container.decode(String.self, forKey: .userID)
    self.userLogin = try container.decode(String.self, forKey: .userLogin)
    self.userDisplayName = try container.decode(String.self, forKey: .userDisplayName)

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

    self.planName = try container.decode(String.self, forKey: .planName)
    self.tier = try container.decode(SubscriptionTier.self, forKey: .tier)
  }
}
