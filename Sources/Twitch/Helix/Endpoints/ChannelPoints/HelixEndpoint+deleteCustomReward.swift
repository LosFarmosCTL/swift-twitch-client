import Foundation

extension HelixEndpoint {
  /// Deletes a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:manage:redemptions`. The broadcaster ID
  /// must match the token’s user. Reward management is limited to rewards created by the
  /// same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-custom-reward
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - rewardID: The identifier of the reward.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func deleteCustomReward(
    _ rewardID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "channel_points/custom_rewards",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("id", rewardID),
        ]
      })
  }
}
