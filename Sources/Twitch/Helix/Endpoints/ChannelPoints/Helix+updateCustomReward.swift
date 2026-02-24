import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == CustomReward, HelixResponseType == CustomReward
{
  public static func updateCustomReward(
    _ rewardID: String,
    broadcasterID: String? = nil,
    title: String? = nil,
    prompt: String? = nil,
    cost: Int? = nil,
    backgroundColor: String? = nil,
    isEnabled: Bool? = nil,
    isUserInputRequired: Bool? = nil,
    isMaxPerStreamEnabled: Bool? = nil,
    maxPerStream: Int? = nil,
    isMaxPerUserPerStreamEnabled: Bool? = nil,
    maxPerUserPerStream: Int? = nil,
    isGlobalCooldownEnabled: Bool? = nil,
    globalCooldownSeconds: Int? = nil,
    isPaused: Bool? = nil,
    shouldRedemptionsSkipRequestQueue: Bool? = nil
  ) -> Self {
    return .init(
      method: "PATCH", path: "channel_points/custom_rewards",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("id", rewardID),
        ]
      },
      body: { _ in
        UpdateCustomRewardBody(
          title: title,
          prompt: prompt,
          cost: cost,
          backgroundColor: backgroundColor,
          isEnabled: isEnabled,
          isUserInputRequired: isUserInputRequired,
          isMaxPerStreamEnabled: isMaxPerStreamEnabled,
          maxPerStream: maxPerStream,
          isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
          maxPerUserPerStream: maxPerUserPerStream,
          isGlobalCooldownEnabled: isGlobalCooldownEnabled,
          globalCooldownSeconds: globalCooldownSeconds,
          isPaused: isPaused,
          shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue)
      },
      makeResponse: {
        guard let reward = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return reward
      })
  }
}

private struct UpdateCustomRewardBody: Encodable, Sendable {
  let title: String?
  let prompt: String?
  let cost: Int?
  let backgroundColor: String?
  let isEnabled: Bool?
  let isUserInputRequired: Bool?
  let isMaxPerStreamEnabled: Bool?
  let maxPerStream: Int?
  let isMaxPerUserPerStreamEnabled: Bool?
  let maxPerUserPerStream: Int?
  let isGlobalCooldownEnabled: Bool?
  let globalCooldownSeconds: Int?
  let isPaused: Bool?
  let shouldRedemptionsSkipRequestQueue: Bool?
}
