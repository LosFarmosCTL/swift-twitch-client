import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeChannelVIP(
    in channel: UserID, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("user_id", userID))

    return .init(method: "DELETE", path: "channels/vips", queryItems: queryItems)
  }
}
