import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func checkAutoModStatus(messages: (id: String, message: String)...)
    -> HelixEndpoint<[AutoModStatus], AutoModStatus, HelixEndpointResponseTypes.Normal>
  {
    return self.checkAutoModStatus(messages: messages)
  }

  public static func checkAutoModStatus(messages: [(id: String, message: String)])
    -> HelixEndpoint<[AutoModStatus], AutoModStatus, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "moderation/enforcements/status",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
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

@MemberwiseInit(.public)
public struct AutoModStatus: Decodable, Sendable {
  public let messageID: String
  public let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case messageID = "msgId"
    case isPermitted
  }
}
