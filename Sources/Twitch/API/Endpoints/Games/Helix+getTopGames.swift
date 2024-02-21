import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Game> {
  public static func getTopGames(
    limit: Int? = nil, after startCursor: String? = nil, before endCursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("after", startCursor),
      ("before", endCursor),
      ("first", limit.map(String.init)))

    return .init(method: "GET", path: "games/top", queryItems: queryItems)
  }
}
