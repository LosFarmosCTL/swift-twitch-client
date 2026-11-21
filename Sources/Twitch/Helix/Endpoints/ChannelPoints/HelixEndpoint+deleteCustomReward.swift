import Foundation

extension HelixEndpoint {
  /// Deletes a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:manage:redemptions`. The broadcaster ID
  /// must match the token’s user. Reward management is limited to rewards created by the
  /// same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channel-points/#delete-custom-reward
  /// ) for request limits and account requirements.
  ///
  /// - Parameter rewardID: The identifier of the reward.
  public static func deleteCustomReward(
    _ rewardID: String
  ) -> HelixEndpoint<Void> {
    .init(
      method: "DELETE", path: "channel_points/custom_rewards",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("id", rewardID),
        ]
      })
  }
}
