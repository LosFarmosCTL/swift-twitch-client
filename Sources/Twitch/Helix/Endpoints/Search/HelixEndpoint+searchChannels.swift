import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func searchChannels(
    for query: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (channels: [Channel], cursor: String?),
    Channel, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "search/channels",
      queryItems: { _ in
        [
          ("query", query),
          ("live_only", liveOnly.map(String.init)),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct Channel: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String
  public let language: String

  public let gameID: String
  public let gameName: String

  public let isLive: Bool
  public let tags: [String]

  public let profileImageURL: String
  public let title: String

  @InitRaw(default: nil, type: Date?.self)
  @NilOnTypeMismatch public var startedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case login = "broadcasterLogin"
    case displayName
    case language = "broadcasterLanguage"
    case gameID = "gameId"
    case gameName
    case isLive
    case tags
    case profileImageURL = "thumbnailUrl"
    case title
    case startedAt
  }
}
