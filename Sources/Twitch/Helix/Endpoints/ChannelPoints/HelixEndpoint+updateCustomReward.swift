import Foundation

extension HelixEndpoint {
  /// Updates a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:manage:redemptions`. The broadcaster ID
  /// must match the token’s user. Reward management is limited to rewards created by the
  /// same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-custom-reward
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - rewardID: The identifier of the reward.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - title: The title shown to viewers, when provided.
  ///   - prompt: The prompt shown when viewers redeem the reward.
  ///   - cost: The Channel Points required for one redemption.
  ///   - backgroundColor: The reward’s background color as a hexadecimal string.
  ///   - isEnabled: Whether the setting is enabled, when provided.
  ///   - isUserInputRequired: Whether redeeming the reward requires user input, when
  ///     provided.
  ///   - isMaxPerStreamEnabled: Whether to enforce the per-stream redemption limit.
  ///   - maxPerStream: The maximum redemptions allowed per stream, when provided.
  ///   - isMaxPerUserPerStreamEnabled: Whether to enforce the per-user, per-stream
  ///     redemption limit.
  ///   - maxPerUserPerStream: The maximum redemptions allowed per user per stream, when
  ///     provided.
  ///   - isGlobalCooldownEnabled: Whether to enforce the reward’s global cooldown.
  ///   - globalCooldownSeconds: The reward’s global cooldown, in seconds, when provided.
  ///   - isPaused: Whether the reward is paused, when provided.
  ///   - shouldRedemptionsSkipRequestQueue: Whether redemptions bypass the request queue,
  ///     when provided.
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
  ) -> HelixEndpoint<CustomReward, CustomReward, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "channel_points/custom_rewards",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
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
        let reward = try $0.requireFirst()

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
