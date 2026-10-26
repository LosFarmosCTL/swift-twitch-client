import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelSubscriptionMessageEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let tier: String
  public let durationMonths: Int
  public let cumulativeMonths: Int
  public let streakMonths: Int?

  public let message: Message

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case tier
    case cumulativeMonths
    case streakMonths
    case durationMonths
    case message
  }

  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
    public let text: String
    public let emotes: [Emote]

    @MemberwiseInit(.public)
    public struct Emote: Decodable, Sendable {
      public let begin: Int
      public let end: Int
      public let id: String
    }
  }
}
