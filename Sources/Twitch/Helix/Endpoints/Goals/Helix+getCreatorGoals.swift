import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [CreatorGoal], HelixResponseType == CreatorGoal
{
  public static func getCreatorGoals(broadcasterID: String? = nil) -> Self {
    return .init(
      method: "GET", path: "goals",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      makeResponse: { $0.data })
  }
}

public struct CreatorGoal: Decodable, Sendable {
  public let id: String
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String
  public let type: CreatorGoalType
  public let description: String
  public let currentAmount: Int
  public let targetAmount: Int
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterName
    case broadcasterLogin
    case type
    case description
    case currentAmount
    case targetAmount
    case createdAt
  }
}

public enum CreatorGoalType: String, Decodable, Sendable {
  case follower
  case subscription
  case subscriptionCount = "subscription_count"
  case newSubscription = "new_subscription"
  case newSubscriptionCount = "new_subscription_count"
}
