import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BlockedTerm> {
  public static func getBlockedTerms(
    inChannel broadcasterID: String,
    limit: Int? = nil,
    after cursor: String? = nil,
    moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "moderation/blocked_terms", queryItems: queryItems)
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
