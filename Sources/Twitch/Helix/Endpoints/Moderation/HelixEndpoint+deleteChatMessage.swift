import Foundation

extension HelixEndpoint {
  /// Deletes a chat message from a channel.
  ///
  /// With a user access token, requires `moderator:manage:chat_messages`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#delete-chat-messages
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - messageID: The identifier of the message.
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  public static func deleteChatMessage(
    in broadcasterID: String,
    messageID: String,
    moderatorID: String? = nil
  ) -> HelixEndpoint<Void> {
    .init(
      method: "DELETE", path: "moderation/chat",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("message_id", messageID),
        ]
      })
  }

  /// Clears all messages from a channel’s chat.
  ///
  /// With a user access token, requires `moderator:manage:chat_messages`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#delete-chat-messages
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  public static func clearChat(
    in broadcasterID: String,
    moderatorID: String? = nil
  ) -> HelixEndpoint<Void> {
    .init(
      method: "DELETE", path: "moderation/chat",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
        ]
      })
  }
}
