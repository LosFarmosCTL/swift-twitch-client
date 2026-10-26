import Foundation

extension HelixEndpoint {
  public static func updateCustomRewardRedemptionStatus(
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
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("reward_id", rewardID),
        ] + redemptionIDs.map { ("id", $0) }
      },
      body: { _ in
        UpdateRedemptionStatusBody(status: status)
      },
      makeResponse: {
        let redemption = try $0.requireFirst()

        return redemption
      })
  }
}

private struct UpdateRedemptionStatusBody: Encodable, Sendable {
  let status: CustomRewardRedemptionStatus
}
