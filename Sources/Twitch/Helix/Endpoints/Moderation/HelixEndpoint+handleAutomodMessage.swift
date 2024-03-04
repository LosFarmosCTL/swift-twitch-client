import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  private static func handleAutomodMessage(messageID: String, action: String) -> Self {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: { auth in
        ["data": ["user_id": auth.userID, "msg_id": messageID, "action": action]]
      }
    )
  }

  public static func approveAutomodMessage(messageID: String) -> Self {
    self.handleAutomodMessage(messageID: messageID, action: "APPROVE")
  }

  public static func denyAutomodMessage(messageID: String) -> Self {
    self.handleAutomodMessage(messageID: messageID, action: "DENY")
  }
}
