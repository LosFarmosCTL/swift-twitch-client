import Foundation

extension HelixEndpoint {
  public static func getTopGames(
    limit: Int? = nil,
    after startCursor: String? = nil,
    before endCursor: String? = nil
  ) -> HelixEndpoint<([Game], String?), Game, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "games/top",
      queryItems: { _ in
        [
          ("after", startCursor),
          ("before", endCursor),
          ("first", limit.map(String.init)),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
