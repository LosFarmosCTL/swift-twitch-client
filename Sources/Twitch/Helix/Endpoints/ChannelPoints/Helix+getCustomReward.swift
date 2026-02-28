import Foundation

extension HelixEndpoint {
  public static func getCustomRewards(
    for broadcasterID: String? = nil,
    ids: [String] = [],
    onlyManageable: Bool? = nil
  ) -> HelixEndpoint<[CustomReward], CustomReward, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channel_points/custom_rewards",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("only_manageable_rewards", onlyManageable.map(String.init)),
        ] + ids.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}

public struct CustomReward: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let id: String
  public let title: String
  public let prompt: String
  public let cost: Int

  public let image: CustomRewardImage?
  public let defaultImage: CustomRewardImage?
  public let backgroundColor: String

  public let isEnabled: Bool
  public let isUserInputRequired: Bool

  public let maxPerStreamSetting: RewardSetting
  public let maxPerUserPerStreamSetting: RewardSetting
  public let globalCooldownSetting: RewardSetting

  public let isPaused: Bool
  public let isInStock: Bool
  public let shouldRedemptionsSkipRequestQueue: Bool

  public let redemptionsRedeemedCurrentStream: Int?
  public let cooldownExpiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterName
    case id
    case title
    case prompt
    case cost
    case image
    case defaultImage
    case backgroundColor
    case isEnabled
    case isUserInputRequired
    case maxPerStreamSetting
    case maxPerUserPerStreamSetting
    case globalCooldownSetting
    case isPaused
    case isInStock
    case shouldRedemptionsSkipRequestQueue
    case redemptionsRedeemedCurrentStream
    case cooldownExpiresAt
  }
}

public struct CustomRewardImage: Decodable, Sendable {
  public let url1x: String
  public let url2x: String
  public let url4x: String

  enum CodingKeys: String, CodingKey {
    case url1x = "url1X"
    case url2x = "url2X"
    case url4x = "url4X"
  }
}

public struct RewardSetting: Decodable, Sendable {
  public let isEnabled: Bool
  public let maxPerStream: Int?
  public let maxPerUserPerStream: Int?
  public let globalCooldownSeconds: Int?
}
