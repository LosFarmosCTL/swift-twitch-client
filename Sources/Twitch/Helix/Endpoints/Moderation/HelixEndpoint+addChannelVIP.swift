import Foundation

extension HelixEndpoint {
  public static func addChannelVIP(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "channels/vips",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
