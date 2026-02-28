import Foundation

extension HelixEndpoint {
  public static func unbanUser(
    _ user: String,
    in channel: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/bans",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("user_id", user),
        ]
      })
  }
}
