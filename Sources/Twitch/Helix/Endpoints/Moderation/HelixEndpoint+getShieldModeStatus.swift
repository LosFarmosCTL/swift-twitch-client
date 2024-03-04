import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ShieldModeStatus, HelixResponseType == ShieldModeStatus
{
  public static func getShieldModeStatus(
    of channel: UserID
  ) -> Self {
    return .init(
      method: "GET", path: "moderation/shield_mode",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      makeResponse: {
        guard let status = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return status
      })
  }
}

public struct ShieldModeStatus: Decodable {
  let isActive: Bool
  let moderatorID: String
  let moderatorName: String
  let moderatorLogin: String
  @NilOnTypeMismatch var lastActivatedAt: Date?

  enum CodingKeys: String, CodingKey {
    case isActive = "is_active"
    case moderatorID = "moderator_id"
    case moderatorName = "moderator_name"
    case moderatorLogin = "moderator_login"
    case lastActivatedAt = "last_activated_at"
  }
}
