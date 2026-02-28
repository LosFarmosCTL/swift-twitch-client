import Foundation

extension HelixEndpoint {
  public static func addChannelVIP(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "channels/vips",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("user_id", userID),
        ]
      })
  }
}
