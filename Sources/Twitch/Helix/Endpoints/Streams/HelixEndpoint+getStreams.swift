import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getStreams(
    userIDs: [String] = [],
    userLogins: [String] = [],
    gameIDs: [String] = [],
    type: StreamTypeFilter? = nil,
    languages: [String] = [],
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (streams: [Stream], cursor: String?),
    Stream, HelixEndpointResponseTypes.Normal
  > {
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
          ("before", beforeCursor),
          ("after", afterCursor),
        ] + userIDs + userLogins + gameIDs + languages
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public enum StreamTypeFilter: String, Sendable {
  case live
  case all
}

@MemberwiseInit(.public)
public struct Stream: Decodable, Sendable {
  public let id: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let gameID: String
  public let gameName: String

  public let type: String
  public let title: String
  public let language: String
  public let tags: [String]
  public let isMature: Bool

  public let viewerCount: Int
  public let startedAt: Date
  public let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case gameID = "gameId"
    case gameName
    case type
    case title
    case language
    case tags
    case isMature
    case viewerCount
    case startedAt
    case thumbnailURL = "thumbnailUrl"
  }
}
