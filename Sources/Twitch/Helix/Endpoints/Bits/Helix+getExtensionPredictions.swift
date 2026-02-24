import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([ExtensionPrediction], PaginationCursor?),
  HelixResponseType == ExtensionPrediction
{
  public static func getExtensionPredictions(
    extensionID: String,
    limit: Int? = nil,
    after cursor: PaginationCursor? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "extensions/predictions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct ExtensionPrediction: Decodable, Sendable {
  public let id: String
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String
  public let title: String
  public let outcomes: [ExtensionPredictionOutcome]
  public let predictionWindow: Int
  public let createdAt: Date
  public let endedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterName
    case title
    case outcomes
    case predictionWindow
    case createdAt
    case endedAt
  }
}

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
