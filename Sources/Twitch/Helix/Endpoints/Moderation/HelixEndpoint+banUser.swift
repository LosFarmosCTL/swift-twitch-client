import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Ban, HelixResponseType == Ban
{
  public static func banUser(
    _ user: UserID, in channel: UserID,
    for duration: Duration? = nil, reason: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "moderation/bans",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      body: { _ in
        BanUserBody(
          userID: user,
          reason: reason,
          duration: duration)
      },
      makeResponse: {
        guard let ban = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return ban
      })
  }
}

private struct BanUserBody: Encodable, Sendable {
  let userID: String
  let reason: String?
  let duration: Duration?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case reason, duration
  }
}

public struct Ban: Decodable, Sendable {
  public let broadcasterID: String
  public let moderatorID: String
  public let userID: String
  public let createdAt: Date
  public let endTime: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case userID = "userId"
    case createdAt, endTime
  }
}
