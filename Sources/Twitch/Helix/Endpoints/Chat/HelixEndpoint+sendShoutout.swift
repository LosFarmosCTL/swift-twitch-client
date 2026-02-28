import Foundation

extension HelixEndpoint {
  public static func sendShoutout(
    from sendingUser: String,
    to receivingUser: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "chat/shoutouts",
      queryItems: { auth in
        [
          ("from_broadcaster_id", sendingUser),
          ("to_broadcaster_id", receivingUser),
          ("moderator_id", auth.userID),
        ]
      })
  }
}
