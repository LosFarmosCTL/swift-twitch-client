import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendChatMessage(
    broadcasterID: String, senderID: String, message: String,
    replyParentMessageID: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "chat/announcements",
      body: SendChatMessageRequestBody(
        broadcasterID: broadcasterID, senderID: senderID, message: message,
        replyParentMessageID: replyParentMessageID))
  }
}

internal struct SendChatMessageRequestBody: Encodable {
  let broadcasterID: String
  let senderID: String
  let message: String

  let replyParentMessageID: String?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case senderID = "sender_id"
    case message

    case replyParentMessageID = "reply_parent_message_id"
  }
}
