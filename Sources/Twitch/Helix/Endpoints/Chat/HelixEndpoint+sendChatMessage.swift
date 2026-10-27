import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Sends a chat message as the authenticated user.
  ///
  /// With a user access token, requires `user:write:chat`. App tokens have additional
  /// grant requirements described in the reference. The sender is the user in the
  /// executing client’s credentials. Messages may contain at most 500 characters.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-chat-message
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - message: The text to send. Maximum 500 characters.
  ///   - replyToMessageID: The ID of the message to reply to; `nil` sends a top-level
  ///     message.
  ///   - isSourceOnly: With an app token, whether to send only to the source channel
  ///     during shared chat. Supplying this field with a user token causes Twitch to
  ///     reject the request with HTTP 400; leave it `nil` for user tokens.
  ///   - pin: Whether to send and pin the message for 20 minutes. Requires
  ///     `moderator:manage:chat_messages` and moderator or broadcaster status. Cannot be
  ///     combined with `replyTo` or `isSourceOnly`; if pinning fails, no message is sent.
  public static func sendChatMessage(
    in broadcasterID: String,
    message: String,
    replyTo replyToMessageID: String? = nil,
    isSourceOnly: Bool? = nil,
    pin: Bool? = nil
  ) -> HelixEndpoint<
    ChatMessageResponse, ChatMessageResponse, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "chat/messages",
      body: { credentials in
        SendChatMessageRequestBody(
          broadcasterID: broadcasterID,
          senderID: credentials.userID,
          message: message,
          replyToMessageID: replyToMessageID,
          isSourceOnly: isSourceOnly,
          pin: pin)
      },
      makeResponse: {
        let messageResponse = try $0.requireFirst()

        return messageResponse
      })
  }
}

/// The message identifier and delivery verdict returned after sending a chat message.
@MemberwiseInit(.public)
public struct ChatMessageResponse: Decodable, Sendable {
  /// The identifier of the message.
  public let messageID: String
  /// Whether Twitch accepted the chat message for delivery.
  public let isSent: Bool

  /// The reason Twitch did not deliver the message, when provided.
  public let dropReason: DropReason?

  enum CodingKeys: String, CodingKey {
    case messageID = "messageId"
    case isSent

    case dropReason
  }

  /// The machine-readable code and explanation for a chat delivery rejection.
  public struct DropReason: Decodable, Sendable {
    /// The Twitch code identifying why the message was dropped.
    public let code: String
    /// The message content or explanatory text supplied by Twitch.
    public let message: String
  }
}

private struct SendChatMessageRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let senderID: String
  let message: String

  let replyToMessageID: String?

  let isSourceOnly: Bool?
  let pin: Bool?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case senderID = "senderId"
    case message, pin

    case replyToMessageID = "replyParentMessageId"
    case isSourceOnly = "forSourceOnly"
  }
}
