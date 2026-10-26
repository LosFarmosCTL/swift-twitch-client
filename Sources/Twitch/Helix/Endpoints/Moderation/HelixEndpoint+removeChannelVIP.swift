import Foundation

extension HelixEndpoint {
  public static func removeChannelVIP(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "DELETE", path: "channels/vips",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
