import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getShieldModeStatus(of broadcasterID: String)
    -> HelixEndpoint<
      ShieldModeStatus, ShieldModeStatus,
      HelixEndpointResponseTypes.Normal
    >
  {
    .init(
      method: "GET", path: "moderation/shield_mode",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      makeResponse: {
        let status = try $0.requireFirst()

        return status
      })
  }
}

@MemberwiseInit(.public)
public struct ShieldModeStatus: Decodable, Sendable {
  public let isActive: Bool
  public let moderatorID: String
  public let moderatorDisplayName: String
  public let moderatorLogin: String

  @InitRaw(default: nil, type: Date?.self)
  @NilOnTypeMismatch public var lastActivatedAt: Date?

  enum CodingKeys: String, CodingKey {
    case moderatorID = "moderatorId"
    case moderatorDisplayName = "moderatorName"
    case moderatorLogin
    case isActive
    case lastActivatedAt
  }
}
