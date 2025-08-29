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

public struct BlockedTerm: Decodable, Sendable {
  public let broadcasterID: String
  public let moderatorID: String

  public let id: String
  public let text: String

  public let createdAt: Date
  public let updatedAt: Date

  public let expiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"

    case id, text, createdAt, updatedAt, expiresAt
  }
}
