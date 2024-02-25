import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  private static func handleAutomodMessage(
    withID msgID: String, action: String, moderatorID: String
  ) -> Self {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: ["data": ["user_id": moderatorID, "msg_id": msgID, "action": action]]
    )
  }

  public static func approveAutomodMessage(
    withID msgID: String, moderatorID: String
  ) -> Self {
    self.handleAutomodMessage(withID: msgID, action: "APPROVE", moderatorID: moderatorID)
  }

  public static func denyAutomodMessage(
    withID msgID: String, moderatorID: String
  ) -> Self {
    self.handleAutomodMessage(withID: msgID, action: "DENY", moderatorID: moderatorID)
  }
}
