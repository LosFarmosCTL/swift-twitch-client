import Foundation

extension HelixEndpoint {
  public static func deleteChatMessage(
    in channel: String,
    messageID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/chat",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("message_id", messageID),
        ]
      })
  }
}
