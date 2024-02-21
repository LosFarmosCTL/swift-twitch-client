import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeChannelModerator(
    for broadcasterID: String, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("user_id", userID))

    return .init(method: "DELETE", path: "moderation/moderators", queryItems: queryItems)
  }
}
