import Foundation

extension HelixEndpoint {
  public static func getTopGames(
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<
    (games: [Game], cursor: String?),
    Game, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "games/top",
      queryItems: { _ in
        [
          ("after", afterCursor),
          ("before", beforeCursor),
          ("first", limit.map(String.init)),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
