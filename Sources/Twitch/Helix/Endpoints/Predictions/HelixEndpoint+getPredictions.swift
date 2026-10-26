import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getPredictions(
    predictionIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (predictions: [Prediction], cursor: String?), Prediction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "predictions",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + predictionIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct Prediction: Decodable, Sendable {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let title: String
  public let winningOutcomeID: String?

  public let outcomes: [PredictionOutcome]
  public let predictionWindow: Int
  public let status: Status

  public let createdAt: Date
  public let endedAt: Date?
  public let lockedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case title
    case winningOutcomeID = "winningOutcomeId"
    case outcomes
    case predictionWindow
    case status
    case createdAt
    case endedAt
    case lockedAt
  }

  public enum Status: String, Decodable, Sendable {
    case active = "ACTIVE"
    case resolved = "RESOLVED"
    case cancelled = "CANCELED"
    case locked = "LOCKED"
  }
}

@MemberwiseInit(.public)
public struct PredictionOutcome: Decodable, Sendable {
  public let id: String
  public let title: String
  public let users: Int
  public let channelPoints: Int
  public let topPredictors: [TopPredictor]?
  public let color: Color

  public enum Color: String, Decodable, Sendable {
    case pink = "PINK"
    case blue = "BLUE"
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
