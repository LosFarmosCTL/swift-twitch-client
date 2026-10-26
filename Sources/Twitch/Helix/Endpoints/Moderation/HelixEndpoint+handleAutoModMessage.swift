import Foundation

extension HelixEndpoint {
  private static func handleAutoModMessage(messageID: String, action: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: { credentials in
        ["data": ["user_id": credentials.userID, "msg_id": messageID, "action": action]]
      }
    )
  }

  public static func approveAutoModMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "APPROVE")
  }

  public static func denyAutoModMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "DENY")
  }
}
