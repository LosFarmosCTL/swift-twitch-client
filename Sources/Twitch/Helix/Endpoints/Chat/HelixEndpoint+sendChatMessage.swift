import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChatMessageResponse, HelixResponseType == ChatMessageResponse
{
  public static func sendChatMessage(
    in channel: UserID, message: String,
    replyParentMessageID: String? = nil,
    forSourceOnly: Bool? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "chat/messages",
      body: { auth in
        SendChatMessageRequestBody(
          broadcasterID: channel,
          senderID: auth.userID,
          message: message,
          replyParentMessageID: replyParentMessageID,
          forSourceOnly: forSourceOnly)
      },
      makeResponse: {
        guard let messageResponse = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return messageResponse
      })
  }
}

public struct ChatMessageResponse: Decodable, Sendable {
  public let messageID: String
  public let isSent: Bool

  public let dropReason: DropReason?

  enum CodingKeys: String, CodingKey {
    case messageID = "messageId"
    case isSent

    case dropReason
  }

  public struct DropReason: Decodable, Sendable {
    let code: String
    let message: String
  }
}

internal struct SendChatMessageRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let senderID: String
  let message: String

  let replyParentMessageID: String?

  let forSourceOnly: Bool?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case senderID = "senderId"
    case message

    case replyParentMessageID = "replyParentMessageId"
    case forSourceOnly
  }
}
