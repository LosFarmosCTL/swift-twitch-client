import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  private static func handleAutomodMessage(
    messageID: String, action: String, moderatorID: String
  ) -> Self {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: ["data": ["user_id": moderatorID, "msg_id": messageID, "action": action]]
    )
  }

  public static func approveAutomodMessage(
    messageID: String, moderatorID: String
  ) -> Self {
    self.handleAutomodMessage(
      messageID: messageID, action: "APPROVE", moderatorID: moderatorID)
  }

  public static func denyAutomodMessage(
    messageID: String, moderatorID: String
  ) -> Self {
    self.handleAutomodMessage(
      messageID: messageID, action: "DENY", moderatorID: moderatorID)
  }
}
