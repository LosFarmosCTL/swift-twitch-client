import Foundation

extension HelixEndpoint {
  /// Gets game categories ordered by viewer count.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-top-games
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
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
      authentication: .either,
      queryItems: { _ in
        [
          ("after", afterCursor),
          ("before", beforeCursor),
          ("first", limit.map(String.init)),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
