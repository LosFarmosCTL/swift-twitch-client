import Foundation

extension HelixEndpoint {
  public static func updateShieldModeStatus(
    of broadcasterID: String,
    isActive: Bool
  ) -> HelixEndpoint<
    ShieldModeStatus, ShieldModeStatus,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/shield_mode",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      }, body: { _ in ["is_active": isActive] },
      makeResponse: {
        let status = try $0.requireFirst()
        return status
      })
  }
}
