import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendShoutout(
    from sendingUser: UserID, to receivingUser: UserID, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("from_broadcaster_id", sendingUser),
      ("to_broadcaster_id", receivingUser),
      ("moderator_id", moderatorID))

    return .init(method: "POST", path: "chat/shoutouts", queryItems: queryItems)
  }
}
