import Foundation

extension HelixEndpoint {
  public static func getPredictions(
    filterIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> HelixEndpoint<
    ([Prediction], String?), Prediction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "predictions",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
        ] + filterIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct Prediction: Decodable, Sendable {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

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
    case broadcasterName

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
    case canceled = "CANCELED"
    case locked = "LOCKED"
  }
}

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

  public struct TopPredictor: Decodable, Sendable {
    public let userID: String
    public let userLogin: String
    public let userName: String

    public let channelPointsUsed: Int
    public let channelPointsWon: Int?

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin
      case userName

      case channelPointsUsed
      case channelPointsWon
    }
  }
}
