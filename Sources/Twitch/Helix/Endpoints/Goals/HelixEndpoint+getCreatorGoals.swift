import Foundation

extension HelixEndpoint {
  /// Gets a broadcaster’s active creator goals.
  ///
  /// With a user access token, requires `channel:read:goals`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/goals/#get-creator-goals
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func getCreatorGoals(broadcasterID: String? = nil)
    -> HelixEndpoint<[CreatorGoal]>
  {
    .init(
      method: "GET", path: "goals",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          )
        ]
      },
      responseType: CreatorGoal.self, makeResponse: { $0.data })
  }
}

/// A broadcaster’s follower or subscription goal and its current progress.
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

  /// Creates a `CreatorGoal` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    type: CreatorGoalType,
    description: String,
    currentAmount: Int,
    targetAmount: Int,
    createdAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.type = type
    self.description = description
    self.currentAmount = currentAmount
    self.targetAmount = targetAmount
    self.createdAt = createdAt
  }

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

/// The follower or subscription metric used to measure a creator goal, preserving
/// unfamiliar values in `rawValue`.
public struct CreatorGoalType: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact goal type string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a creator goal type from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a creator goal type from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Increases the number of Bits used on the channel.
  public static let newBit = Self(rawValue: "new_bit")
  /// Increases the number of unique Cheerers.
  public static let newCheerer = Self(rawValue: "new_cheerer")
  /// Tracks the channel’s follower count.
  public static let follower = Self(rawValue: "follower")
  /// Tracks subscription points.
  public static let subscription = Self(rawValue: "subscription")
  /// Tracks the number of subscriptions. Encoded as `"subscription_count"`.
  public static let subscriptionCount = Self(rawValue: "subscription_count")
  /// Tracks points from new subscriptions. Encoded as `"new_subscription"`.
  public static let newSubscription = Self(rawValue: "new_subscription")
  /// Tracks the number of new subscriptions. Encoded as `"new_subscription_count"`.
  public static let newSubscriptionCount = Self(rawValue: "new_subscription_count")
}
