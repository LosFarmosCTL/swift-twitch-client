import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendShoutout(
    from sendingUserId: String, to receivingUserId: String, moderatorId: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("from_broadcaster_id", sendingUserId),
      ("to_broadcaster_id", receivingUserId),
      ("moderator_id", moderatorId))

    return .init(method: "POST", path: "chat/shoutouts", queryItems: queryItems)
  }
}
