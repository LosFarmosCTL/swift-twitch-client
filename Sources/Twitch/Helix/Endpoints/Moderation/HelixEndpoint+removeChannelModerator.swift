import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeChannelModerator(
    in channel: UserID, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("user_id", userID))

    return .init(method: "DELETE", path: "moderation/moderators", queryItems: queryItems)
  }
}
