import Foundation

public struct ChannelGoalEndEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let type: String
  public let description: String?

  public let isAchieved: Bool
  public let currentAmount: Int
  public let targetAmount: Int

  public let startedAt: Date
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case type, description
    case isAchieved, currentAmount, targetAmount
    case startedAt, endedAt
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
