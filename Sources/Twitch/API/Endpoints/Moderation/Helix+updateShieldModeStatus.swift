import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func updateShieldModeStatus(inChannel broadcasterID: String, isActive: Bool)
    async throws -> ShieldModeStatus
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<ShieldModeStatus>?) = try await self.request(
      .put("moderation/shield_mode"), with: queryItems, jsonBody: ["is_active": isActive])

    guard let status = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return status
  }
}
