import Foundation
import MemberwiseInit

extension HelixEndpoint {
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

@MemberwiseInit(.public)
public struct Category: Decodable, Sendable {
  public let id: String
  public let name: String
  public let boxArtURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtURL = "boxArtUrl"
  }
}
