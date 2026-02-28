import Foundation

extension HelixEndpoint {
  public static func updateRedemptionStatus(
    _ redemptionIDs: [String],
    rewardID: String,
    status: CustomRewardRedemptionStatus,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<
    CustomRewardRedemption,
    CustomRewardRedemption,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PATCH", path: "channel_points/custom_rewards/redemptions",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("reward_id", rewardID),
        ] + redemptionIDs.map { ("id", $0) }
      },
      body: { _ in
        UpdateRedemptionStatusBody(status: status)
      },
      makeResponse: {
        guard let redemption = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return redemption
      })
  }
}

private struct UpdateRedemptionStatusBody: Encodable, Sendable {
  let status: CustomRewardRedemptionStatus
}
