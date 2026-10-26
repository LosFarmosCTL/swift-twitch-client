import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a broadcaster’s custom Channel Points rewards.
  ///
  /// With a user access token, requires `channel:read:redemptions` or
  /// `channel:manage:redemptions`. The broadcaster ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-custom-reward
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - rewardIDs: Reward IDs to retrieve; an empty array requests all rewards in the
  ///     channel.
  ///   - onlyManageable: Whether to return only rewards manageable by the calling
  ///     application.
  public static func getCustomRewards(
    for broadcasterID: String? = nil,
    rewardIDs: [String] = [],
    onlyManageable: Bool? = nil
  ) -> HelixEndpoint<[CustomReward], CustomReward, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channel_points/custom_rewards",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("only_manageable_rewards", onlyManageable.map(String.init)),
        ] + rewardIDs.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}

/// A broadcaster’s custom Channel Points reward and redemption restrictions.
@MemberwiseInit(.public)
public struct CustomReward: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The prompt shown when viewers redeem the reward.
  public let prompt: String
  /// The Channel Points required to redeem the reward.
  public let cost: Int

  /// The image details, when provided.
  public let image: CustomRewardImage?
  /// The default reward image, when provided.
  public let defaultImage: CustomRewardImage?
  /// The background color as a hexadecimal color string.
  public let backgroundColor: String

  /// Whether the setting is enabled.
  public let isEnabled: Bool
  /// Whether redeeming the reward requires user input.
  public let isUserInputRequired: Bool

  /// The per-stream redemption limit configuration.
  public let maxPerStreamSetting: RewardSetting
  /// The per-user, per-stream redemption limit configuration.
  public let maxPerUserPerStreamSetting: RewardSetting
  /// The global cooldown configuration.
  public let globalCooldownSetting: RewardSetting

  /// Whether the reward is paused.
  public let isPaused: Bool
  /// Whether the reward is in stock.
  public let isInStock: Bool
  /// Whether redemptions bypass the request queue.
  public let shouldRedemptionsSkipRequestQueue: Bool

  /// The redemptions made during the current stream, when provided.
  public let redemptionsRedeemedCurrentStream: Int?
  /// The end of the reward cooldown, when provided.
  public let cooldownExpiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
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

/// A custom reward’s image URLs at the supported display scales.
@MemberwiseInit(.public)
public struct CustomRewardImage: Decodable, Sendable {
  /// The image URL at 1× scale.
  public let url1x: String
  /// The image URL at 2× scale.
  public let url2x: String
  /// The image URL at 4× scale.
  public let url4x: String

  enum CodingKeys: String, CodingKey {
    case url1x = "url1X"
    case url2x = "url2X"
    case url4x = "url4X"
  }
}

/// A reward restriction’s enabled state and configured value.
@MemberwiseInit(.public)
public struct RewardSetting: Decodable, Sendable {
  /// Whether the setting is enabled.
  public let isEnabled: Bool
  /// The maximum redemptions allowed per stream, when provided.
  public let maxPerStream: Int?
  /// The maximum redemptions allowed per user per stream, when provided.
  public let maxPerUserPerStream: Int?
  /// The reward’s global cooldown, in seconds, when provided.
  public let globalCooldownSeconds: Int?
}
