import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<AutomodStatus> {
  public static func checkAutomodStatus(
    in channel: UserID, messages: (id: String, message: String)...
  ) -> Self {
    return self.checkAutomodStatus(in: channel, messages: messages)
  }

  public static func checkAutomodStatus(
    in channel: String, messages: [(id: String, message: String)]
  ) -> Self {
    let queryItems = self.makeQueryItems(("broadcaster_id", channel))

    return .init(
      method: "POST", path: "moderation/enforcements/status", queryItems: queryItems,
      body: ["data": messages.map { ["msg_id": $0.id, "msg_text": $0.message] }])
  }
}

public struct AutomodStatus: Decodable {
  let messageID: String
  let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case messageID = "msg_id"
    case isPermitted = "is_permitted"
  }
}
