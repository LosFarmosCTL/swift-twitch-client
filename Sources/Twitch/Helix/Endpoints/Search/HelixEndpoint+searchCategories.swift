import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Searches Twitch game categories by name.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/search/#search-categories
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - query: The search text.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields ``SearchCategoriesResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func searchCategories(
    for query: String,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<SearchCategoriesResponse> {
    .init(
      method: "GET", path: "search/categories",
      authentication: .either,
      queryItems: { _ in
        [
          ("query", query),
          ("after", cursor),
          ("first", limit.map(String.init)),
        ]
      },
      responseType: Category.self,
      makeResponse: {
        SearchCategoriesResponse(categories: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A Twitch category returned by category search.
@MemberwiseInit(.public)
public struct Category: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The URL of the category's box art image.
  public let boxArtURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtURL = "boxArtUrl"
  }
}

/// A page of search categories.
@MemberwiseInit(.public)
public struct SearchCategoriesResponse: Sendable {
  /// The categories on this page.
  public let categories: [Category]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?
}
