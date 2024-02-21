import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BannedUser> {
  public static func getBannedUsers(
    for broadcasterId: String,
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil,
    before endCursor: String? = nil
  ) -> Self {
    var queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("after", startCursor),
      ("before", endCursor),
      ("first", limit.map(String.init)))

    queryItems.append(
      contentsOf: filterUserIDs.compactMap { URLQueryItem(name: "user_id", value: $0) })

    return .init(
      method: "GET", path: "moderation/banned", queryItems: queryItems, body: nil)
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
