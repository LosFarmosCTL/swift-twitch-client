import Foundation

extension HelixEndpoint {
  public static func unbanUser(
    _ userID: String,
    in broadcasterID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/bans",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
