import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  public static func sendShoutout(
    from sendingUser: UserID, to receivingUser: UserID
  ) -> Self {
    return .init(
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
