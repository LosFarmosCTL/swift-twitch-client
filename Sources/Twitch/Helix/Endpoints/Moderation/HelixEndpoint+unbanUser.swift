import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func unbanUser(
    _ user: UserID, in channel: UserID, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("moderator_id", moderatorID),
      ("user_id", user))

    return .init(method: "DELETE", path: "moderation/bans", queryItems: queryItems)
  }
}
