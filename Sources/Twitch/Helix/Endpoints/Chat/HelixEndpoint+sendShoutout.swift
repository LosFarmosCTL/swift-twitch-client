import Foundation

extension HelixEndpoint {
  public static func sendShoutout(
    from fromBroadcasterID: String,
    to toBroadcasterID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "chat/shoutouts",
      queryItems: { credentials in
        [
          ("from_broadcaster_id", fromBroadcasterID),
          ("to_broadcaster_id", toBroadcasterID),
          ("moderator_id", credentials.userID),
        ]
      })
  }
}
