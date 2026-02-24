import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Video], PaginationCursor?), HelixResponseType == Video
{
  public static func getVideos(
    ids: [String] = [],
    userID: UserID? = nil,
    gameID: String? = nil,
    language: String? = nil,
    period: VideoPeriod? = nil,
    sort: VideoSort? = nil,
    type: VideoTypeFilter? = nil,
    limit: Int? = nil,
    after startCursor: String? = nil,
    before endCursor: String? = nil
  ) -> Self {
    let idQueryItems = ids.map { ("id", $0) }

    return .init(
      method: "GET", path: "videos",
      queryItems: { _ in
        [
          ("user_id", userID),
          ("game_id", gameID),
          ("language", language),
          ("period", period?.rawValue),
          ("sort", sort?.rawValue),
          ("type", type?.rawValue),
          ("first", limit.map(String.init)),
          ("after", startCursor),
          ("before", endCursor),
        ] + idQueryItems
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public enum VideoPeriod: String, Sendable {
  case all
  case day
  case week
  case month
}

public enum VideoSort: String, Sendable {
  case time
  case trending
  case views
}

public enum VideoTypeFilter: String, Sendable {
  case all
  case archive
  case highlight
  case upload
}

public struct Video: Decodable, Sendable {
  public let id: String
  public let streamID: String?
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let title: String
  public let description: String
  public let createdAt: Date
  public let publishedAt: Date
  public let url: String
  public let thumbnailURL: String
  public let viewable: String
  public let viewCount: Int
  public let language: String
  public let type: VideoType
  public let duration: String
  public let mutedSegments: [MutedSegment]?

  enum CodingKeys: String, CodingKey {
    case id
    case streamID = "streamId"
    case userID = "userId"
    case userLogin
    case userName
    case title
    case description
    case createdAt
    case publishedAt
    case url
    case thumbnailURL = "thumbnailUrl"
    case viewable
    case viewCount
    case language
    case type
    case duration
    case mutedSegments
  }
}

public enum VideoType: String, Decodable, Sendable {
  case archive
  case highlight
  case upload
}

public struct MutedSegment: Decodable, Sendable {
  public let duration: Int
  public let offset: Int
}
