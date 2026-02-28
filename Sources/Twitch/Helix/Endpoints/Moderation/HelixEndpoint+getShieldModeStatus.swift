import Foundation

extension HelixEndpoint {
  public static func getShieldModeStatus(of channel: String)
    -> HelixEndpoint<
      ShieldModeStatus, ShieldModeStatus,
      HelixEndpointResponseTypes.Normal
    >
  {
    .init(
      method: "GET", path: "moderation/shield_mode",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      makeResponse: {
        guard let status = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return status
      })
  }
}

public struct ShieldModeStatus: Decodable, Sendable {
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
