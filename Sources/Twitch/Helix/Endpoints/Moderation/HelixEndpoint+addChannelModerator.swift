import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func addChannelModerator(
    in channel: String, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("user_id", userID))

    return .init(method: "POST", path: "moderation/moderators", queryItems: queryItems)
  }
}
