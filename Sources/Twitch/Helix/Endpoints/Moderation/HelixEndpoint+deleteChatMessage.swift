import Foundation

extension HelixEndpoint {
  public static func deleteChatMessage(
    in broadcasterID: String,
    messageID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/chat",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("message_id", messageID),
        ]
      })
  }
}
