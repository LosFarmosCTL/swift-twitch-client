import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getBlockedTerms(
    inChannel broadcasterID: String, limit: Int? = nil, after cursor: String? = nil
  ) async throws -> (terms: [BlockedTerm], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId),
      ("first", limit.map(String.init)), ("after", cursor))

    let (rawResponse, result): (_, HelixData<BlockedTerm>?) = try await self.request(
      .get("moderation/blocked_terms"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public struct BlockedTerm: Decodable {
  let broadcasterID: String
  let moderatorID: String

  let id: String
  let text: String

  let createdAt: Date
  let updatedAt: Date

  let expiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case moderatorID = "moderator_id"

    case id, text

    case createdAt = "created_at"
    case updatedAt = "updated_at"

    case expiresAt = "expires_at"
  }
}
