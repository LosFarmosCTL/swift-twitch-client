import Foundation

extension HelixEndpoint {
  public static func addChannelModerator(userID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/moderators",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("user_id", userID),
        ]
      })
  }
}
