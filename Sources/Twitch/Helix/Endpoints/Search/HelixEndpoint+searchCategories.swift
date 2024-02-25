import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Category> {
  public static func searchCategories(
    for searchQuery: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("query", searchQuery),
      ("after", cursor),
      ("first", limit.map(String.init)))

    return .init(method: "GET", path: "search/categories", queryItems: queryItems)
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
