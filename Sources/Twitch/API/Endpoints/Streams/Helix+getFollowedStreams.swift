import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getFollowedStreams(limit: Int? = nil, after cursor: String? = nil)
    async throws -> (streams: [Stream], cursor: String?)
  {
    let queryItems = self.makeQueryItems(
      ("user_id", self.authenticatedUserId), ("first", limit.map(String.init)),
      ("after", cursor))

    let (rawResponse, result): (_, HelixData<Stream>?) = try await self.request(
      .get("streams/followed"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}
