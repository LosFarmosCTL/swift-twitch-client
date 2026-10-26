import Foundation
import MemberwiseInit

public typealias ChannelPointsCustomRewardRedemptionUpdateEvent =
  ChannelPointsCustomRewardRedemptionAddEvent

@MemberwiseInit(.public)
public struct ChannelPointsCustomRewardRedemptionAddEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let userInput: String
  public let status: String
  public let reward: Reward
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

  @MemberwiseInit(.public)
  public struct Reward: Decodable, Sendable {
    public let id: String
    public let title: String
    public let cost: Int
    public let prompt: String
  }

  public enum Status: String, Decodable, Sendable {
    case unknown
    case unfulfilled
    case fulfilled
    case cancelled = "canceled"
  }
}
