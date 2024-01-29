import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getTopGames(
    limit: Int? = nil, after endCursor: String? = nil, before startCursor: String? = nil
  ) async throws -> (games: [Game], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("after", endCursor), ("before", startCursor), ("first", limit.map(String.init)))

    let (rawResponse, result): (_, HelixData<Game>?) = try await self.request(
      .get("games/top"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}
