import Foundation

extension HelixEndpoint {
  public static func updateShieldModeStatus(
    of channel: String,
    isActive: Bool
  ) -> HelixEndpoint<
    ShieldModeStatus, ShieldModeStatus,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/shield_mode",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in ["is_active": isActive] },
      makeResponse: {
        let status = try $0.requireFirst()
        return status
      })
  }
}
