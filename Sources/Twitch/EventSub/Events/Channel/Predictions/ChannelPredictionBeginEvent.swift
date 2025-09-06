import Foundation

public typealias ChannelPredictionProgressEvent = ChannelPredictionBeginEvent

public struct ChannelPredictionBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let outcomes: [Outcome]
  public let startedAt: Date
  public let locksAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case title, outcomes
    case startedAt, locksAt
  }

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

    public struct TopPredictor: Decodable, Sendable {
      public let userID: String
      public let userLogin: String
      public let userName: String

      public let channelPointsUsed: Int
      public let channelPointsWon: Int?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin, userName

        case channelPointsUsed, channelPointsWon
      }
    }
  }

}
