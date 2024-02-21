import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<AutomodStatus> {
  public static func checkAutomodStatus(
    for broadcasterID: String, messages: (msgId: String, msg: String)...
  ) -> Self {
    return self.checkAutomodStatus(for: broadcasterID, messageList: messages)
  }

  public static func checkAutomodStatus(
    for broadcasterID: String, messageList: [(msgId: String, msg: String)]
  ) -> Self {
    let queryItems = self.makeQueryItems(("broadcaster_id", broadcasterID))

    return .init(
      method: "POST", path: "moderation/enforcements/status", queryItems: queryItems,
      body: ["data": messageList.map { ["msg_id": $0.msgId, "msg_text": $0.msg] }])
  }
}

public struct AutomodStatus: Decodable {
  let msgId: String
  let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case msgId = "msg_id"
    case isPermitted = "is_permitted"
  }
}
