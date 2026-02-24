import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Game], String?),
  HelixResponseType == Game
{
  public static func getTopGames(
    limit: Int? = nil, after startCursor: String? = nil, before endCursor: String? = nil
  ) -> Self {
    return .init(
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
