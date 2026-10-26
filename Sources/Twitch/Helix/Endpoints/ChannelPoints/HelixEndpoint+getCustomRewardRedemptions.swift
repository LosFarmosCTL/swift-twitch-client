import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getCustomRewardRedemptions(
    rewardID: String,
    broadcasterID: String? = nil,
    status: CustomRewardRedemptionStatus? = nil,
    redemptionIDs: [String] = [],
    sort: CustomRewardRedemptionSort? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (redemptions: [CustomRewardRedemption], cursor: String?),
    CustomRewardRedemption,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "channel_points/custom_rewards/redemptions",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("reward_id", rewardID),
          ("status", status?.rawValue),
          ("sort", sort?.rawValue),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + redemptionIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct CustomRewardRedemption: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let id: String
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let userInput: String
  public let status: CustomRewardRedemptionStatus
  public let redeemedAt: Date
  public let reward: CustomRewardRedemptionReward

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case id
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case userInput
    case status
    case redeemedAt
    case reward
  }
}

@MemberwiseInit(.public)
public struct CustomRewardRedemptionReward: Decodable, Sendable {
  public let id: String
  public let title: String
  public let prompt: String
  public let cost: Int
}

public enum CustomRewardRedemptionStatus: String, Codable, Sendable {
  case cancelled = "CANCELED"
  case fulfilled = "FULFILLED"
  case unfulfilled = "UNFULFILLED"
}

public enum CustomRewardRedemptionSort: String, Codable, Sendable {
  case oldest = "OLDEST"
  case newest = "NEWEST"
}
