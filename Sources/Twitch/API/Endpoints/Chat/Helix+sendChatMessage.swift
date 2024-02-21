import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendChatMessage(
    broadcasterId: String, senderId: String, message: String,
    replyParentMessageId: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "chat/announcements",
      body: SendChatMessageRequestBody(
        broadcasterId: broadcasterId, senderId: senderId, message: message,
        replyParentMessageId: replyParentMessageId))
  }
}

internal struct SendChatMessageRequestBody: Encodable {
  let broadcasterId: String
  let senderId: String
  let message: String

  let replyParentMessageId: String?

  enum CodingKeys: String, CodingKey {
    case broadcasterId = "broadcaster_id"
    case senderId = "sender_id"
    case message

    case replyParentMessageId = "reply_parent_message_id"
  }
}
