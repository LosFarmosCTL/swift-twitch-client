import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func addChannelVIP(
    in channel: String, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("user_id", userID))

    return .init(method: "POST", path: "channels/vips", queryItems: queryItems)
  }
}
