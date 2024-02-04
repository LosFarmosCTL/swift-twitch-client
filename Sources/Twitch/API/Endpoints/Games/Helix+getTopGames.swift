import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getTopGames(
    limit: Int? = nil, after startCursor: String? = nil, before endCursor: String? = nil
  ) async throws -> (games: [Game], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("after", startCursor), ("before", endCursor), ("first", limit.map(String.init)))

    let (rawResponse, result): (_, HelixData<Game>?) = try await self.request(
      .get("games/top"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}
