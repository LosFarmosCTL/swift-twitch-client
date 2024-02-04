import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getBannedUsers(
    userIDs: [String]? = nil, limit: Int? = nil, after startCursor: String? = nil,
    before endCursor: String? = nil
  ) async throws -> (games: [BannedUser], cursor: String?) {
    var queryItems = self.makeQueryItems(
      ("broadcaster_id", self.authenticatedUserId), ("after", startCursor),
      ("before", endCursor), ("first", limit.map(String.init)))

    queryItems.append(
      contentsOf: userIDs?.compactMap { URLQueryItem(name: "user_id", value: $0) } ?? [])

    let (rawResponse, result): (_, HelixData<BannedUser>?) = try await self.request(
      .get("moderation/banned"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public struct BannedUser: Decodable {
  let userId: String
  let userLogin: String
  let userName: String
  let expiresAt: Date
  let createdAt: Date
  let reason: String?
  let moderatorId: String
  let moderatorLogin: String
  let moderatorName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case expiresAt = "expires_at"
    case createdAt = "created_at"
    case reason
    case moderatorId = "moderator_id"
    case moderatorLogin = "moderator_login"
    case moderatorName = "moderator_name"
  }
}
