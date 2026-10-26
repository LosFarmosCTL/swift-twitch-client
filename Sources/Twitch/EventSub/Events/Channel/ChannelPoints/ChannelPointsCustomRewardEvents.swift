import Foundation
import MemberwiseInit

// events contain identical shape of data
/// The payload for channel points custom reward update notifications.
///
/// Uses the same payload fields as ``ChannelPointsCustomRewardAddEvent``.
public typealias ChannelPointsCustomRewardUpdateEvent = ChannelPointsCustomRewardAddEvent
/// The payload for channel points custom reward remove notifications.
///
/// Uses the same payload fields as ``ChannelPointsCustomRewardAddEvent``.
public typealias ChannelPointsCustomRewardRemoveEvent = ChannelPointsCustomRewardAddEvent

/// An EventSub notification delivered when a custom Channel Points reward is created.
@MemberwiseInit(.public)
public struct ChannelPointsCustomRewardAddEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// Whether the setting is enabled.
  public let isEnabled: Bool
  /// Whether the reward is paused.
  public let isPaused: Bool
  /// Whether the reward is in stock.
  public let isInStock: Bool

  /// The title shown to viewers.
  public let title: String
  /// The Channel Points required to redeem the reward.
  public let cost: Int
  /// The prompt shown when viewers redeem the reward.
  public let prompt: String

  /// Whether redeeming the reward requires user input.
  public let isUserInputRequired: Bool
  /// Whether redemptions bypass the request queue.
  public let shouldRedemptionsSkipRequestQueue: Bool

  /// The per-stream redemption limit; `nil` means the limit is disabled or absent.
  public let maxPerStream: Int?
  /// The per-user, per-stream redemption limit; `nil` means the limit is disabled or
  /// absent.
  public let maxPerUserPerStream: Int?

  /// The background color as a hexadecimal color string.
  public let backgroundColor: String

  /// The image details, when provided.
  public let image: RewardImage?
  /// The default reward image, when provided.
  public let defaultImage: RewardImage?
  /// The interval required between redemptions; `nil` means the cooldown is disabled or
  /// absent.
  public let globalCooldown: Duration?

  /// The end of the reward cooldown, when provided.
  public let cooldownExpiresAt: Date?
  /// The redemptions made during the current stream, when provided.
  public let redemptionsRedeemedCurrentStream: Int?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case isEnabled
    case isPaused
    case isInStock
    case title
    case cost
    case prompt
    case isUserInputRequired
    case shouldRedemptionsSkipRequestQueue
    case maxPerStream
    case maxPerUserPerStream
    case backgroundColor
    case image
    case defaultImage
    case globalCooldown
    case cooldownExpiresAt
    case redemptionsRedeemedCurrentStream
  }

  /// Decodes a reward, mapping disabled limits and cooldowns to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    isPaused = try container.decode(Bool.self, forKey: .isPaused)
    isInStock = try container.decode(Bool.self, forKey: .isInStock)
    title = try container.decode(String.self, forKey: .title)
    cost = try container.decode(Int.self, forKey: .cost)
    prompt = try container.decode(String.self, forKey: .prompt)
    isUserInputRequired = try container.decode(Bool.self, forKey: .isUserInputRequired)
    shouldRedemptionsSkipRequestQueue = try container.decode(
      Bool.self, forKey: .shouldRedemptionsSkipRequestQueue)
    backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
    image = try container.decodeIfPresent(RewardImage.self, forKey: .image)
    defaultImage = try container.decodeIfPresent(RewardImage.self, forKey: .defaultImage)
    cooldownExpiresAt = try container.decodeIfPresent(
      Date.self, forKey: .cooldownExpiresAt)
    redemptionsRedeemedCurrentStream = try container.decodeIfPresent(
      Int.self, forKey: .redemptionsRedeemedCurrentStream)

    let maxPerStream = try container.decodeIfPresent(
      MaxPerStream.self, forKey: .maxPerStream)
    let maxPerUserPerStream = try container.decodeIfPresent(
      MaxPerUserPerStream.self, forKey: .maxPerUserPerStream)
    let globalCooldown = try container.decodeIfPresent(
      GlobalCooldown.self, forKey: .globalCooldown)

    self.maxPerStream =
      if let maxPerStream, maxPerStream.isEnabled { maxPerStream.value } else { nil }
    self.maxPerUserPerStream =
      if let maxPerUserPerStream, maxPerUserPerStream.isEnabled {
        maxPerUserPerStream.value
      } else {
        nil
      }
    self.globalCooldown =
      if let globalCooldown, globalCooldown.isEnabled {
        .seconds(globalCooldown.seconds)
      } else {
        nil
      }
  }

  private struct MaxPerStream: Decodable, Sendable {
    let isEnabled: Bool
    let value: Int
  }

  private struct MaxPerUserPerStream: Decodable, Sendable {
    let isEnabled: Bool
    let value: Int
  }

  private struct GlobalCooldown: Decodable, Sendable {
    let isEnabled: Bool
    let seconds: Int
  }

  /// Image URLs for a custom reward at each supported display scale.
  @MemberwiseInit(.public)
  public struct RewardImage: Decodable, Sendable {
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
}
