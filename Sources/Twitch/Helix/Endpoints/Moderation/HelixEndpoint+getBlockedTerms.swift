import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getBlockedTerms(
    in broadcasterID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (terms: [BlockedTerm], cursor: String?), BlockedTerm,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/blocked_terms",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

@MemberwiseInit(.public)
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
