import Foundation

public typealias ChannelPointsCustomRewardRedemptionUpdateEvent =
  ChannelPointsCustomRewardRedemptionAddEvent

public struct ChannelPointsCustomRewardRedemptionAddEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let userInput: String
  public let status: String
  public let reward: Reward
  public let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case id

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case userID = "userId"
    case userLogin = "userLogin"
    case userName = "userName"

    case userInput, status, reward, redeemedAt
  }

  public struct Reward: Decodable, Sendable {
    public let id: String
    public let title: String
    public let cost: Int
    public let prompt: String
  }

  public enum Status: String, Decodable, Sendable {
    case unknown, unfulfilled, fulfilled, canceled
  }
}
