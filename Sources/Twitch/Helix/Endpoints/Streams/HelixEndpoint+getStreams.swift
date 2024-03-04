import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Stream], PaginationCursor?),
  HelixResponseType == Stream
{
  public static func getStreams(
    userIDs: [String] = [],
    userLogins: [String] = [],
    gameIDs: [String] = [],
    type: StreamType? = nil,
    languages: [String] = [],
    limit: Int? = nil,
    before endCursor: String? = nil,
    after startCursor: String? = nil
  ) -> Self {
    let userIDs = userIDs.compactMap { ("user_id", $0) }
    let userLogins = userLogins.compactMap { ("user_login", $0) }
    let gameIDs = gameIDs.compactMap { ("game_id", $0) }
    let languages = languages.compactMap { ("language", $0) }

    return .init(
      method: "GET", path: "streams",
      queryItems: { _ in
        [
          ("type", type?.rawValue),
          ("first", limit.map(String.init)),
          ("before", endCursor),
          ("after", startCursor),
        ] + userIDs + userLogins + gameIDs + languages
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public enum StreamType: String {
  case live
  case all
}

public struct Stream: Decodable {
  let id: String

  let userID: String
  let userLogin: String
  let userName: String

  let gameID: String
  let gameName: String

  let type: String
  let title: String
  let language: String
  let tags: [String]
  let isMature: Bool

  let viewerCount: Int
  let startedAt: Date
  let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"

    case gameID = "game_id"
    case gameName = "game_name"

    case type
    case title
    case language
    case tags
    case isMature = "is_mature"

    case viewerCount = "viewer_count"
    case startedAt = "started_at"
    case thumbnailURL = "thumbnail_url"
  }
}
