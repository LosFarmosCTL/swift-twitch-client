import Foundation

extension HelixEndpoint {
  /// Creates a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:manage:redemptions`. The broadcaster ID
  /// must match the token’s user. Reward management is limited to rewards created by the
  /// same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-custom-rewards
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - title: The title shown to viewers.
  ///   - cost: The Channel Points required for one redemption.
  ///   - prompt: The prompt shown when viewers redeem the reward.
  ///   - isEnabled: Whether the setting is enabled, when provided.
  ///   - backgroundColor: The reward’s background color as a hexadecimal string.
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
  ///   - shouldRedemptionsSkipRequestQueue: Whether redemptions bypass the request queue,
  ///     when provided.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
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
  ) -> HelixEndpoint<CustomReward, CustomReward, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "channel_points/custom_rewards",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          )
        ]
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
        let reward = try $0.requireFirst()

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
