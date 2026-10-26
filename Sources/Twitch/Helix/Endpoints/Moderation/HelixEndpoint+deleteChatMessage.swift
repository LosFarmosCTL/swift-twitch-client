import Foundation

extension HelixEndpoint {
  /// Deletes a chat message from a channel.
  ///
  /// With a user access token, requires `moderator:manage:chat_messages`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-chat-messages
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - messageID: The identifier of the message.
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
