import Foundation

/// The payload for channel goal progress notifications.
///
/// Uses the same payload fields as ``ChannelGoalBeginEvent``.
public typealias ChannelGoalProgressEvent = ChannelGoalBeginEvent

/// An EventSub notification delivered when a creator goal begins.
public struct ChannelGoalBeginEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The goal metric, such as followers, subscriptions, subscription points, or Bits.
  public let type: String
  /// The descriptive text supplied by Twitch, when provided.
  public let description: String?

  /// The progress achieved toward the goal, measured in the units defined by `type`.
  public let currentAmount: Int
  /// The amount needed to complete the goal, measured in the units defined by `type`.
  public let targetAmount: Int

  /// The time the activity started.
  public let startedAt: Date

  /// Creates a `ChannelGoalBeginEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    type: String,
    description: String? = nil,
    currentAmount: Int,
    targetAmount: Int,
    startedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.type = type
    self.description = description
    self.currentAmount = currentAmount
    self.targetAmount = targetAmount
    self.startedAt = startedAt
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case type
    case description
    case currentAmount
    case targetAmount
    case startedAt
  }

  enum GoalType: String, Codable {
    case follow, subscription
    case subscriptionCount = "subscription_count"
    case newSubscription = "new_subscription"
    case newSubscriptionCount = "new_subscription_count"
    case newBit = "new_bit"
    case newCheerer = "new_cheerer"
  }
}
