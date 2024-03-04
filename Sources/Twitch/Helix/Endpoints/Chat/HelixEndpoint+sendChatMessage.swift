import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChatMessageResponse, HelixResponseType == ChatMessageResponse
{
  public static func sendChatMessage(
    in channel: UserID, message: String,
    replyParentMessageID: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "chat/announcements",
      body: { auth in
        SendChatMessageRequestBody(
          broadcasterID: channel,
          senderID: auth.userID,
          message: message,
          replyParentMessageID: replyParentMessageID)
      },
      makeResponse: {
        guard let messageResponse = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return messageResponse
      })
  }
}

public struct ChatMessageResponse: Decodable {
  public let messageID: String
  public let isSent: Bool

  public let dropReason: DropReason?

  enum CodingKeys: String, CodingKey {
    case messageID = "message_id"
    case isSent = "is_sent"

    case dropReason = "drop_reason"
  }

  public struct DropReason: Decodable {
    let code: String
    let message: String
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
