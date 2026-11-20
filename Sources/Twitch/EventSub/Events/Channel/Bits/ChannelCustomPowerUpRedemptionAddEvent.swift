import Foundation
import MemberwiseInit

/// A viewer redeemed a broadcaster-defined Bits Power-up.
@MemberwiseInit(.public)
public struct ChannelCustomPowerUpRedemptionAddEvent: Event {
  public let id: String
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String
  /// The viewer’s input, or an empty string when no input was supplied.
  public let userInput: String
  /// The redemption status reported by Twitch.
  public let status: String
  public let customPowerUp: CustomPowerUp
  public let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case id, userLogin, userInput, status, customPowerUp, redeemedAt
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userDisplayName = "userName"
  }

  /// The custom Power-up’s details at the time it was redeemed.
  @MemberwiseInit(.public)
  public struct CustomPowerUp: Decodable, Sendable {
    public let id: String
    public let title: String
    /// The number of Bits required for the redemption.
    public let bits: Int
    public let prompt: String
  }
}
