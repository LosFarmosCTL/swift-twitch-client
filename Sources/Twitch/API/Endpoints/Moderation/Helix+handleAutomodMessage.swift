import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  private static func handleAutomodMessage(
    withID msgID: String, action: String, moderatorId: String
  ) -> Self {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: ["data": ["user_id": moderatorId, "msg_id": msgID, "action": action]]
    )
  }

  public static func approveAutomodMessage(
    withID msgID: String, moderatorId: String
  ) -> Self {
    self.handleAutomodMessage(withID: msgID, action: "APPROVE", moderatorId: moderatorId)
  }

  public static func denyAutomodMessage(
    withID msgID: String, moderatorId: String
  ) -> Self {
    self.handleAutomodMessage(withID: msgID, action: "DENY", moderatorId: moderatorId)
  }
}
