import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets game categories by Twitch ID, name, or IGDB ID.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-games
  /// ) for request limits and account requirements.
  ///
  /// Provide at least one game ID, game name, or IGDB ID. The selector arrays can be
  /// combined; leaving all three empty causes Twitch to reject the request. This factory
  /// does not validate the selection.
  ///
  /// - Parameters:
  ///   - gameIDs: The game IDs to include in the request. Defaults to `[]`.
  ///   - gameNames: The game names to include in the request. Defaults to `[]`.
  ///   - igdbIDs: The IGDB IDs to include in the request. Defaults to `[]`.
  public static func getGames(
    gameIDs: [String] = [],
    gameNames: [String] = [],
    igdbIDs: [String] = []
  ) -> HelixEndpoint<[Game], Game, HelixEndpointResponseTypes.Normal> {
    let idQueryItems = gameIDs.map { ("id", $0) }
    let nameQueryItems = gameNames.map { ("name", $0) }
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

/// A Twitch game or category with its box art and external game identifier.
@MemberwiseInit(.public)
public struct Game: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The URL for box art.
  public let boxArtURL: String
  /// The identifier of the igdb.
  public let igdbID: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtURL = "boxArtUrl"
    case igdbID = "igdbId"
  }
}
