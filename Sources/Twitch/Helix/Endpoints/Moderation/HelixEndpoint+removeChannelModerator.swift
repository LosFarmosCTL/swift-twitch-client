import Foundation

extension HelixEndpoint {
  public static func removeChannelModerator(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "DELETE", path: "moderation/moderators",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
