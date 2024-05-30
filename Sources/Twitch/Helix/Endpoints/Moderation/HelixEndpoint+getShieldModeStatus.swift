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
  public let isActive: Bool
  public let moderatorID: String
  public let moderatorName: String
  public let moderatorLogin: String
  @NilOnTypeMismatch public var lastActivatedAt: Date?

  enum CodingKeys: String, CodingKey {
    case moderatorID = "moderatorId"
    case moderatorName, moderatorLogin
    case isActive, lastActivatedAt
  }
}
