import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<Ban> {
  public static func banUser(
    withID userID: String, inChannel channelID: String,
    for timeoutLength: Duration? = nil, reason: String? = nil, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channelID),
      ("moderator_id", moderatorID))

    let body = BanUserBody(userID: userID, reason: reason, duration: timeoutLength)

    return .init(
      method: "POST", path: "moderation/bans", queryItems: queryItems, body: body)
  }
}

private struct BanUserBody: Encodable {
  let userID: String
  let reason: String?
  let duration: Duration?

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case reason
    case duration
  }
}

public struct Ban: Decodable {
  let broadcasterID: String
  let moderatorID: String
  let userID: String
  let createdAt: Date
  let endTime: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case moderatorID = "moderator_id"
    case userID = "user_id"
    case createdAt = "created_at"
    case endTime = "end_time"
  }
}
