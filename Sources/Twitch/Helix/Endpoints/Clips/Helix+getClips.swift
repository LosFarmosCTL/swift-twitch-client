import Foundation

extension HelixEndpoint {
  public static func getClips(
    ids: [String] = [],
    broadcasterID: String? = nil,
    gameID: String? = nil,
    startedAt: Date? = nil,
    endedAt: Date? = nil,
    limit: Int? = nil,
    before cursorBefore: String? = nil,
    after cursorAfter: String? = nil,
    isFeatured: Bool? = nil
  ) -> HelixEndpoint<([Clip], String?), Clip, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "clips",
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID),
          ("game_id", gameID),
          ("started_at", startedAt?.formatted(.iso8601)),
          ("ended_at", endedAt?.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("before", cursorBefore),
          ("after", cursorAfter),
          ("is_featured", isFeatured.map(String.init)),
        ] + ids.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct Clip: Decodable, Sendable {
  public let id: String
  public let url: String
  public let embedURL: String

  public let broadcasterID: String
  public let broadcasterName: String

  public let creatorID: String
  public let creatorName: String

  public let videoID: String
  public let gameID: String

  public let language: String
  public let title: String
  public let viewCount: Int
  public let createdAt: Date
  public let thumbnailURL: String
  public let duration: Double
  public let vodOffset: Int?
  public let isFeatured: Bool

  enum CodingKeys: String, CodingKey {
    case id, url
    case embedURL = "embedUrl"

    case broadcasterID = "broadcasterId"
    case broadcasterName

    case creatorID = "creatorId"
    case creatorName

    case videoID = "videoId"
    case gameID = "gameId"

    case language, title
    case viewCount
    case createdAt
    case thumbnailURL = "thumbnailUrl"
    case duration
    case vodOffset
    case isFeatured
  }
}
