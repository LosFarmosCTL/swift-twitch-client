import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a broadcaster’s active creator goals.
  ///
  /// With a user access token, requires `channel:read:goals`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-creator-goals
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func getCreatorGoals(broadcasterID: String? = nil)
    -> HelixEndpoint<[CreatorGoal], CreatorGoal, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "goals",
      queryItems: { credentials in
        [("broadcaster_id", broadcasterID ?? credentials.userID)]
      },
      makeResponse: { $0.data })
  }
}

/// A broadcaster’s follower or subscription goal and its current progress.
@MemberwiseInit(.public)
public struct CreatorGoal: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The metric used to measure progress toward the goal.
  public let type: CreatorGoalType
  /// The descriptive text supplied by Twitch.
  public let description: String
  /// The progress achieved toward the goal, measured in the units defined by `type`.
  public let currentAmount: Int
  /// The amount needed to complete the goal, measured in the units defined by `type`.
  public let targetAmount: Int
  /// The time the resource was created.
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case broadcasterLogin
    case type
    case description
    case currentAmount
    case targetAmount
    case createdAt
  }
}

/// The follower or subscription metric used to measure a creator goal.
public enum CreatorGoalType: String, Decodable, Sendable {
  /// Tracks the channel’s follower count.
  case follower
  /// Tracks subscription points.
  case subscription
  /// Tracks the number of subscriptions. Encoded as `"subscription_count"`.
  case subscriptionCount = "subscription_count"
  /// Tracks points from new subscriptions. Encoded as `"new_subscription"`.
  case newSubscription = "new_subscription"
  /// Tracks the number of new subscriptions. Encoded as `"new_subscription_count"`.
  case newSubscriptionCount = "new_subscription_count"
}
