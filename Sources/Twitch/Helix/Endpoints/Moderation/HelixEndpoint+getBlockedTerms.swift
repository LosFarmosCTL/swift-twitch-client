import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([BlockedTerm], PaginationCursor?), HelixResponseType == BlockedTerm
{
  public static func getBlockedTerms(
    in channel: UserID,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "moderation/blocked_terms",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
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
