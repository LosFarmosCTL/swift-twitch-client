import Foundation
import MemberwiseInit

/// The payload for channel points custom reward redemption update notifications.
///
/// Uses the same payload fields as ``ChannelPointsCustomRewardRedemptionAddEvent``.
public typealias ChannelPointsCustomRewardRedemptionUpdateEvent =
  ChannelPointsCustomRewardRedemptionAddEvent

/// An EventSub notification delivered when a viewer redeems a custom Channel Points
/// reward.
@MemberwiseInit(.public)
public struct ChannelPointsCustomRewardRedemptionAddEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The text entered by the user when redeeming the reward.
  public let userInput: String
  /// The redemption’s fulfillment state, such as `unfulfilled`, `fulfilled`, or
  /// `canceled`.
  public let status: String
  /// The reward details.
  public let reward: Reward
  /// The time the reward was redeemed.
  public let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case userInput
    case status
    case reward
    case redeemedAt
  }

  /// The identity, title, prompt, and Channel Points cost of the redeemed reward.
  @MemberwiseInit(.public)
  public struct Reward: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The title shown to viewers.
    public let title: String
    /// The Channel Points required to redeem the reward.
    public let cost: Int
    /// The prompt shown when viewers redeem the reward.
    public let prompt: String
  }

  /// The fulfillment state reported for a custom reward redemption.
  public enum Status: String, Decodable, Sendable {
    /// A value Twitch did not classify or this client does not recognize.
    case unknown
    /// The reward redemption is awaiting fulfillment.
    case unfulfilled
    /// The reward or entitlement has been fulfilled.
    case fulfilled
    /// The operation was cancelled. Encoded as `"canceled"`.
    case cancelled = "canceled"
  }
}
