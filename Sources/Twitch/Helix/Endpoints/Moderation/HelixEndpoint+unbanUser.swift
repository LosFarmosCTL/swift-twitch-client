import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  public static func unbanUser(
    _ user: UserID, in channel: UserID
  ) -> Self {
    return .init(
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
