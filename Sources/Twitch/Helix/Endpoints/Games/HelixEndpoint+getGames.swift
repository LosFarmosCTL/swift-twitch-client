import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Game],
  HelixResponseType == Game
{
  public static func getGames(
    gameIDs: [String] = [], names: [String] = [], igdbIDs: [String] = []
  ) -> Self {
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

public struct Game: Decodable {
  public let id: String
  public let name: String
  public let boxArtUrl: String
  public let igdbID: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtUrl = "box_art_url"
    case igdbID = "igdb_id"
  }
}
