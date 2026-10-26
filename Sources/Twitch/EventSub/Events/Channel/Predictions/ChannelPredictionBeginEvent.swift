import Foundation
import MemberwiseInit

public typealias ChannelPredictionProgressEvent = ChannelPredictionBeginEvent

@MemberwiseInit(.public)
public struct ChannelPredictionBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let title: String
  public let outcomes: [Outcome]
  public let startedAt: Date
  public let locksAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case outcomes
    case startedAt
    case locksAt
  }

  @MemberwiseInit(.public)
  public struct Outcome: Decodable, Sendable {
    public let id: String
    public let title: String
    public let color: Color

    public let users: Int?
    public let channelPoints: Int?
    public let topPredictors: [TopPredictor]?

    public enum Color: String, Decodable, Sendable {
      case pink, blue
    }

    @MemberwiseInit(.public)
    public struct TopPredictor: Decodable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userDisplayName: String

      public let channelPointsUsed: Int
      public let channelPointsWon: Int?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin
        case userDisplayName = "userName"
        case channelPointsUsed
        case channelPointsWon
      }
    }
  }

}
