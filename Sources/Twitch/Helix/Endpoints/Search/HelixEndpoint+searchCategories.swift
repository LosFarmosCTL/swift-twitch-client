import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Searches Twitch game categories by name.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#search-categories
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - query: The search text.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(categories: [Category], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func searchCategories(
    for query: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (categories: [Category], cursor: String?),
    Category, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "search/categories",
      authentication: .either,
      queryItems: { _ in
        [
          ("query", query),
          ("after", afterCursor),
          ("first", limit.map(String.init)),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A Twitch category returned by category search.
@MemberwiseInit(.public)
public struct Category: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The URL for box art.
  public let boxArtURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtURL = "boxArtUrl"
  }
}
