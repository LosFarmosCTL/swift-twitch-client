import Foundation

extension HelixEndpoint {
  private static func handleAutomodMessage(messageID: String, action: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: { auth in
        ["data": ["user_id": auth.userID, "msg_id": messageID, "action": action]]
      }
    )
  }

  public static func approveAutomodMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutomodMessage(messageID: messageID, action: "APPROVE")
  }

  public static func denyAutomodMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutomodMessage(messageID: messageID, action: "DENY")
  }
}
