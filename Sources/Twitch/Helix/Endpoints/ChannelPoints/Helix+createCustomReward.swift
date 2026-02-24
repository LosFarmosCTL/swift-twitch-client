import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == CustomReward, HelixResponseType == CustomReward
{
  public static func createCustomReward(
    title: String,
    cost: Int,
    prompt: String? = nil,
    isEnabled: Bool? = nil,
    backgroundColor: String? = nil,
    isUserInputRequired: Bool? = nil,
    isMaxPerStreamEnabled: Bool? = nil,
    maxPerStream: Int? = nil,
    isMaxPerUserPerStreamEnabled: Bool? = nil,
    maxPerUserPerStream: Int? = nil,
    isGlobalCooldownEnabled: Bool? = nil,
    globalCooldownSeconds: Int? = nil,
    shouldRedemptionsSkipRequestQueue: Bool? = nil,
    broadcasterID: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "channel_points/custom_rewards",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      body: { _ in
        CreateCustomRewardBody(
          title: title,
          cost: cost,
          prompt: prompt,
          isEnabled: isEnabled,
          backgroundColor: backgroundColor,
          isUserInputRequired: isUserInputRequired,
          isMaxPerStreamEnabled: isMaxPerStreamEnabled,
          maxPerStream: maxPerStream,
          isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
          maxPerUserPerStream: maxPerUserPerStream,
          isGlobalCooldownEnabled: isGlobalCooldownEnabled,
          globalCooldownSeconds: globalCooldownSeconds,
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

private struct CreateCustomRewardBody: Encodable, Sendable {
  let title: String
  let cost: Int
  let prompt: String?
  let isEnabled: Bool?
  let backgroundColor: String?
  let isUserInputRequired: Bool?
  let isMaxPerStreamEnabled: Bool?
  let maxPerStream: Int?
  let isMaxPerUserPerStreamEnabled: Bool?
  let maxPerUserPerStream: Int?
  let isGlobalCooldownEnabled: Bool?
  let globalCooldownSeconds: Int?
  let shouldRedemptionsSkipRequestQueue: Bool?
}
