import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getExtensionPredictions(
    extensionID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (predictions: [ExtensionPrediction], cursor: String?), ExtensionPrediction,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/predictions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct ExtensionPrediction: Decodable, Sendable {
  public let id: String
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String
  public let title: String
  public let outcomes: [ExtensionPredictionOutcome]
  public let predictionWindow: Int
  public let createdAt: Date
  public let endedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case title
    case outcomes
    case predictionWindow
    case createdAt
    case endedAt
  }
}

@MemberwiseInit(.public)
public struct ExtensionPredictionOutcome: Decodable, Sendable {
  public let id: String
  public let title: String
  public let users: Int
  public let channelPoints: Int
  public let color: Color

  public enum Color: String, Decodable, Sendable {
    case pink = "PINK"
    case blue = "BLUE"
  }
}
