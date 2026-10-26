import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getClips(
    clipIDs: [String] = [],
    broadcasterID: String? = nil,
    gameID: String? = nil,
    startedAt: Date? = nil,
    endedAt: Date? = nil,
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil,
    isFeatured: Bool? = nil
  ) -> HelixEndpoint<
    (clips: [Clip], cursor: String?),
    Clip, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "clips",
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID),
          ("game_id", gameID),
          ("started_at", startedAt?.formatted(.iso8601)),
          ("ended_at", endedAt?.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("before", beforeCursor),
          ("after", afterCursor),
          ("is_featured", isFeatured.map(String.init)),
        ] + clipIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct Clip: Decodable, Sendable {
  public let id: String
  public let url: String
  public let embedURL: String

  public let broadcasterID: String
  public let broadcasterDisplayName: String

  public let creatorID: String
  public let creatorDisplayName: String

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
    case id
    case url
    case embedURL = "embedUrl"
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case creatorID = "creatorId"
    case creatorDisplayName = "creatorName"
    case videoID = "videoId"
    case gameID = "gameId"
    case language
    case title
    case viewCount
    case createdAt
    case thumbnailURL = "thumbnailUrl"
    case duration
    case vodOffset
    case isFeatured
  }
}
