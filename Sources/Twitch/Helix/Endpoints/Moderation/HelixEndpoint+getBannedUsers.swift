import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([BannedUser], PaginationCursor?), HelixResponseType == BannedUser
{
  public static func getBannedUsers(
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil,
    before endCursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "moderation/banned",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
          ("before", endCursor),
        ] + filterUserIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

public struct BannedUser: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let expiresAt: Date
  public let createdAt: Date

  public let reason: String?

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case expiresAt, createdAt, reason

    case moderatorID = "moderatorId"
    case moderatorLogin, moderatorName
  }
}
