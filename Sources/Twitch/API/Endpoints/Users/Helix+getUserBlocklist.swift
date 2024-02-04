import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getUserBlocklist(limit: Int? = nil, after cursor: String? = nil)
    async throws -> (blockedUsers: [BlockedUser], cursor: String?)
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", self.authenticatedUserId), ("first", limit.map(String.init)),
      ("after", cursor))

    let (rawResponse, result): (_, HelixData<BlockedUser>?) = try await self.request(
      .get("users/blocks"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public struct BlockedUser: Decodable {
  let userId: String
  let userLogin: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case displayName = "display_name"
  }
}
