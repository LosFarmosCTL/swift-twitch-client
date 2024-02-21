import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func unbanUser(
    withID userID: String, inChannel channelID: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channelID),
      ("moderator_id", moderatorID),
      ("user_id", userID))

    return .init(method: "DELETE", path: "moderation/bans", queryItems: queryItems)
  }
}
