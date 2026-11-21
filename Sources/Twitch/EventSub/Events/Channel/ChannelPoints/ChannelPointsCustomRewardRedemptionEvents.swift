import Foundation

/// The payload for channel points custom reward redemption update notifications.
///
/// Uses the same payload fields as ``ChannelPointsCustomRewardRedemptionAddEvent``.
public typealias ChannelPointsCustomRewardRedemptionUpdateEvent =
  ChannelPointsCustomRewardRedemptionAddEvent

/// An EventSub notification delivered when a viewer redeems a custom Channel Points
/// reward.
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

  /// Creates a `ChannelPointsCustomRewardRedemptionAddEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    userInput: String,
    status: String,
    reward: Reward,
    redeemedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.userInput = userInput
    self.status = status
    self.reward = reward
    self.redeemedAt = redeemedAt
  }

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
  public struct Reward: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The title shown to viewers.
    public let title: String
    /// The Channel Points required to redeem the reward.
    public let cost: Int
    /// The prompt shown when viewers redeem the reward.
    public let prompt: String

    /// Creates a `Reward` value.
    public init(
      id: String,
      title: String,
      cost: Int,
      prompt: String
    ) {
      self.id = id
      self.title = title
      self.cost = cost
      self.prompt = prompt
    }
  }
}
