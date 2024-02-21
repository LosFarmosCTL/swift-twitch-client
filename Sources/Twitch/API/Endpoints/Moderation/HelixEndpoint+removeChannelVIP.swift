import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeChannelVIP(
    for broadcasterID: String, userID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("user_id", userID))

    return .init(method: "DELETE", path: "channels/vips", queryItems: queryItems)
  }
}
