import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func addChannelModerator(
    for broadcasterID: String, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("user_id", userID))

    return .init(method: "POST", path: "moderation/moderators", queryItems: queryItems)
  }
}
