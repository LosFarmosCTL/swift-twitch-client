import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendShoutout(
    from sendingUserID: String, to receivingUserID: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("from_broadcaster_id", sendingUserID),
      ("to_broadcaster_id", receivingUserID),
      ("moderator_id", moderatorID))

    return .init(method: "POST", path: "chat/shoutouts", queryItems: queryItems)
  }
}
