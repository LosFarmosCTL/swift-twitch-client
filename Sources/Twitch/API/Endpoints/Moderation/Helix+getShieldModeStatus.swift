import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getShieldModeStatus(forChannel broadcasterID: String) async throws
    -> ShieldModeStatus
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<ShieldModeStatus>?) = try await self.request(
      .get("moderation/shield_mode"), with: queryItems)

    guard let status = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return status
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
