import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([CustomRewardRedemption], PaginationCursor?),
  HelixResponseType == CustomRewardRedemption
{
  public static func getCustomRewardRedemptions(
    rewardID: String,
    broadcasterID: UserID? = nil,
    status: CustomRewardRedemptionStatus? = nil,
    ids: [String] = [],
    sort: CustomRewardRedemptionSort? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "channel_points/custom_rewards/redemptions",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("reward_id", rewardID),
          ("status", status?.rawValue),
          ("sort", sort?.rawValue),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + ids.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct CustomRewardRedemption: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let id: String
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let userInput: String
  public let status: CustomRewardRedemptionStatus
  public let redeemedAt: Date
  public let reward: CustomRewardRedemptionReward

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterName
    case id
    case userID = "userId"
    case userLogin
    case userName
    case userInput
    case status
    case redeemedAt
    case reward
  }
}

public struct CustomRewardRedemptionReward: Decodable, Sendable {
  public let id: String
  public let title: String
  public let prompt: String
  public let cost: Int
}

public enum CustomRewardRedemptionStatus: String, Codable, Sendable {
  case canceled = "CANCELED"
  case fulfilled = "FULFILLED"
  case unfulfilled = "UNFULFILLED"
}

public enum CustomRewardRedemptionSort: String, Codable, Sendable {
  case oldest = "OLDEST"
  case newest = "NEWEST"
}
