import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func banUser(
    withID userID: String, inChannel channelID: String,
    for timeoutLength: Duration? = nil, reason: String? = nil
  ) async throws -> Ban {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channelID), ("moderator_id", self.authenticatedUserId))

    let body = BanUserBody(userId: userID, reason: reason, duration: timeoutLength)

    let (rawResponse, result): (_, HelixData<Ban>?) = try await self.request(
      .post("moderation/bans"), with: queryItems, jsonBody: body)

    guard let ban = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return ban
  }
}

private struct BanUserBody: Encodable {
  let userId: String
  let reason: String?
  let duration: Duration?

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
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
