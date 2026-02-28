import Foundation

extension HelixEndpoint {
  public static func getGames(
    gameIDs: [String] = [],
    names: [String] = [],
    igdbIDs: [String] = []
  ) -> HelixEndpoint<[Game], Game, HelixEndpointResponseTypes.Normal> {
    let idQueryItems = gameIDs.map { ("id", $0) }
    let nameQueryItems = names.map { ("name", $0) }
    let igdbQueryItems = igdbIDs.map { ("igdb_id", $0) }

    return .init(
      method: "GET", path: "games",
      queryItems: { _ in
        idQueryItems + nameQueryItems + igdbQueryItems
      },
      makeResponse: {
        $0.data
      })
  }
}

public struct Game: Decodable, Sendable {
  public let id: String
  public let name: String
  public let boxArtUrl: String
  public let igdbID: String

  enum CodingKeys: String, CodingKey {
    case id, name, boxArtUrl
    case igdbID = "igdbId"
  }
}
