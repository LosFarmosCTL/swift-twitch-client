import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s custom Bits Power-ups.
  ///
  /// Requires a user access token with `bits:read`. The broadcaster must match the
  /// token’s user. At most 50 Power-up IDs may be supplied.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-custom-power-up
  /// ) for account requirements and request limits.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s user ID; `nil` uses the authenticated user.
  ///   - powerUpIDs: IDs to filter by; an empty array requests all custom Power-ups.
  public static func getCustomPowerUps(
    for broadcasterID: String? = nil,
    powerUpIDs: [String] = []
  ) -> HelixEndpoint<[CustomPowerUp], CustomPowerUp, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "bits/custom_power_ups",
      queryItems: { credentials in
        [("broadcaster_id", broadcasterID ?? credentials.userID)]
          + powerUpIDs.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}

/// A broadcaster’s custom Bits Power-up and its redemption restrictions.
@MemberwiseInit(.public)
public struct CustomPowerUp: Decodable, Sendable {
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The broadcaster’s login name.
  public let broadcasterLogin: String
  /// The broadcaster’s display name.
  public let broadcasterDisplayName: String
  /// The Power-up ID.
  public let id: String
  /// The Power-up’s title.
  public let title: String
  /// The prompt shown when redeeming the Power-up.
  public let prompt: String
  /// The Bits required for one redemption.
  public let bits: Int
  /// The custom images, if uploaded.
  public let image: CustomRewardImage?
  /// The default Power-up images.
  public let defaultImage: CustomRewardImage
  /// The hexadecimal background color.
  public let backgroundColor: String
  /// Whether the Power-up is enabled.
  public let isEnabled: Bool
  /// Whether redemption requires user input.
  public let isUserInputRequired: Bool
  /// The per-stream redemption limit.
  public let maxPerStreamSetting: RewardSetting
  /// The per-user, per-stream redemption limit.
  public let maxPerUserPerStreamSetting: RewardSetting
  /// The cooldown configuration.
  public let globalCooldownSetting: RewardSetting
  /// Whether redemptions are paused.
  public let isPaused: Bool
  /// Whether the Power-up is in stock.
  public let isInStock: Bool
  /// Redemptions during this stream, when the limit is enabled and the stream is live.
  public let redemptionsRedeemedCurrentStream: Int?
  /// The cooldown expiry, if currently cooling down.
  public let cooldownExpiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case id, title, prompt, bits, image, defaultImage, backgroundColor
    case isEnabled, isUserInputRequired, maxPerStreamSetting, maxPerUserPerStreamSetting
    case globalCooldownSetting, isPaused, isInStock
    case redemptionsRedeemedCurrentStream, cooldownExpiresAt
  }
}
