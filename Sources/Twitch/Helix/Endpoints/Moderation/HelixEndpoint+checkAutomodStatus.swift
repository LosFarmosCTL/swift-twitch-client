import Foundation

extension HelixEndpoint {
  public static func checkAutomodStatus(messages: (id: String, message: String)...)
    -> HelixEndpoint<[AutomodStatus], AutomodStatus, HelixEndpointResponseTypes.Normal>
  {
    return self.checkAutomodStatus(messages: messages)
  }

  public static func checkAutomodStatus(messages: [(id: String, message: String)])
    -> HelixEndpoint<[AutomodStatus], AutomodStatus, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "moderation/enforcements/status",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      body: { _ in
        [
          "data": messages.map {
            ["msg_id": $0.id, "msg_text": $0.message]
          }
        ]
      },
      makeResponse: { $0.data })
  }
}

public struct AutomodStatus: Decodable, Sendable {
  public let messageID: String
  public let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case messageID = "msgId"
    case isPermitted
  }
}
