import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func sendChatMessage(
    in broadcasterID: String,
    message: String,
    replyTo replyToMessageID: String? = nil,
    isSourceOnly: Bool? = nil
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
          isSourceOnly: isSourceOnly)
      },
      makeResponse: {
        let messageResponse = try $0.requireFirst()

        return messageResponse
      })
  }
}

@MemberwiseInit(.public)
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
    public let code: String
    public let message: String
  }
}

private struct SendChatMessageRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let senderID: String
  let message: String

  let replyToMessageID: String?

  let isSourceOnly: Bool?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case senderID = "senderId"
    case message

    case replyToMessageID = "replyParentMessageId"
    case isSourceOnly = "forSourceOnly"
  }
}
