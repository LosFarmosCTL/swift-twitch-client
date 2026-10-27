import Foundation

extension HelixEndpoint {
  private static func handleAutoModMessage(messageID: String, action: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/automod/message",
      body: { credentials in
        ["user_id": credentials.userID, "msg_id": messageID, "action": action]
      }
    )
  }

  /// Approves a message held by AutoMod.
  ///
  /// With a user access token, requires `moderator:manage:automod`. App tokens have
  /// additional grant requirements described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#manage-held-automod-messages
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - messageID: The identifier of the message.
  public static func approveAutoModMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "ALLOW")
  }

  /// Denies a message held by AutoMod.
  ///
  /// With a user access token, requires `moderator:manage:automod`. App tokens have
  /// additional grant requirements described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#manage-held-automod-messages
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - messageID: The identifier of the message.
  public static func denyAutoModMessage(messageID: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "DENY")
  }
}
