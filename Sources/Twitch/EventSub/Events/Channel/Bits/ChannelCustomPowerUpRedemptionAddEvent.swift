import Foundation

/// An EventSub notification delivered when a viewer redeems a broadcaster-defined Bits Power-up.
public struct ChannelCustomPowerUpRedemptionAddEvent: Event {
  /// The unique identifier of this redemption.
  public let id: String
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The Twitch user ID of the viewer who redeemed the Power-up.
  public let userID: String
  /// The login name of the viewer who redeemed the Power-up.
  public let userLogin: String
  /// The display name of the viewer who redeemed the Power-up.
  public let userDisplayName: String
  /// The viewer's input text, or an empty string when no input was supplied.
  public let userInput: String
  /// The redemption status reported by Twitch.
  public let status: String
  /// Snapshot of the custom Power-up's configuration when it was redeemed.
  public let customPowerUp: CustomPowerUp
  /// The time the Power-up was redeemed.
  public let redeemedAt: Date

  /// Creates a `ChannelCustomPowerUpRedemptionAddEvent` value.
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
    customPowerUp: CustomPowerUp,
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
    self.customPowerUp = customPowerUp
    self.redeemedAt = redeemedAt
  }

  enum CodingKeys: String, CodingKey {
    case id, userLogin, userInput, status, customPowerUp, redeemedAt
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userDisplayName = "userName"
  }

  /// The custom Power-up's details at the time it was redeemed.
  public struct CustomPowerUp: Decodable, Sendable {
    /// The unique identifier of the custom Power-up.
    public let id: String
    /// The display title of the custom Power-up.
    public let title: String
    /// The number of Bits required for the redemption.
    public let bits: Int
    /// The prompt shown to viewers when redeeming the Power-up.
    public let prompt: String

    /// Creates a `CustomPowerUp` value.
    public init(
      id: String,
      title: String,
      bits: Int,
      prompt: String
    ) {
      self.id = id
      self.title = title
      self.bits = bits
      self.prompt = prompt
    }
  }
}
