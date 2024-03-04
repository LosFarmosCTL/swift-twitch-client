import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  public static func removeChannelVIP(userID: String) -> Self {
    return .init(
      method: "DELETE", path: "channels/vips",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("user_id", userID),
        ]
      })
  }
}
