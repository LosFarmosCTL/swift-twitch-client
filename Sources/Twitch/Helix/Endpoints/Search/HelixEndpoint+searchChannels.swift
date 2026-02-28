import Foundation

extension HelixEndpoint {
  public static func searchChannels(
    for searchQuery: String,
    liveOnly: Bool? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<([Channel], String?), Channel, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "search/channels",
      queryItems: { _ in
        [
          ("query", searchQuery),
          ("live_only", liveOnly.map(String.init)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct Channel: Decodable, Sendable {
  public let id: String
  public let login: String
  public let name: String
  public let language: String

  public let gameID: String
  public let gameName: String

  public let isLive: Bool
  public let tags: [String]

  public let profilePictureURL: String
  public let title: String
  @NilOnTypeMismatch public var startedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case login = "broadcasterLogin"
    case name = "displayName"
    case language = "broadcasterLanguage"

    case gameID = "gameId"
    case gameName

    case isLive, tags

    case profilePictureURL = "thumbnailUrl"
    case title, startedAt
  }
}
