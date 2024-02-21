import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<ShieldModeStatus> {
  public static func updateShieldModeStatus(
    inChannel broadcasterID: String, isActive: Bool, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID))

    return .init(
      method: "PUT", path: "moderation/shield_mode", queryItems: queryItems,
      body: ["is_active": isActive])
  }
}
