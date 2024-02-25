import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<ShieldModeStatus> {
  public static func getShieldModeStatus(
    forChannel broadcasterID: String, moderatorId: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorId))

    return .init(
      method: "GET", path: "moderation/shield_mode", queryItems: queryItems)
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
