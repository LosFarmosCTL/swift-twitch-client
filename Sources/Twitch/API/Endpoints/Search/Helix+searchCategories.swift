import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func searchCategories(
    for searchQuery: String, limit: Int? = nil, after cursor: String? = nil
  ) async throws -> (games: [Category], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("query", searchQuery), ("after", cursor), ("first", limit.map(String.init)))

    let (rawResponse, result): (_, HelixData<Category>?) = try await self.request(
      .get("search/categories"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
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
