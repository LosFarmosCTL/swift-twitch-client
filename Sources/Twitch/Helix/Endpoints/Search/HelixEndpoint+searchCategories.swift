import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Category], PaginationCursor?),
  HelixResponseType == Category
{
  public static func searchCategories(
    for searchQuery: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "search/categories",
      queryItems: { _ in
        [
          ("query", searchQuery),
          ("after", cursor),
          ("first", limit.map(String.init)),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

public struct Category: Decodable {
  let id: String
  let name: String
  let boxArtUrl: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtUrl = "box_art_url"
  }
}
