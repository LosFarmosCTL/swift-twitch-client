import Foundation

extension HelixEndpoint {
  /// Updates the fulfillment status of custom reward redemptions.
  ///
  /// With a user access token, requires `channel:manage:redemptions`. The broadcaster ID
  /// must match the token’s user. Reward management is limited to rewards created by the
  /// same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-redemption-status
  /// ) for request limits and account requirements.
  ///
  /// Although multiple redemption IDs can be updated, executing this endpoint yields
  /// only the first redemption in Twitch’s response.
  ///
  /// - Parameters:
  ///   - redemptionIDs: The redemption IDs to include in the request.
  ///   - rewardID: The identifier of the reward.
  ///   - status: The new fulfillment state: `.fulfilled` or `.cancelled`. Twitch does not
  ///     allow resetting a redemption to `.unfulfilled`.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
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
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
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
