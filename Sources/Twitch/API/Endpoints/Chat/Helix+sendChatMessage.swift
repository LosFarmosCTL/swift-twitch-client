import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func sendChatMessage(
    in channelId: String, message: String, replyingTo replyParentMessageId: String? = nil
  ) async throws {
    (_, _) =
      try await self.request(
        .post("chat/announcements"),
        jsonBody: SendChatMessageRequestBody(
          broadcasterId: channelId, senderId: self.authenticatedUserId, message: message,
          replyParentMessageId: replyParentMessageId)) as (_, HelixData<Int>?)
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
