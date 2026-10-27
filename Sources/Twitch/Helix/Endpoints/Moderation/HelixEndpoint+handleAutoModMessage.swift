import Foundation

extension HelixEndpoint {
  private static func handleAutoModMessage(
    messageID: String, action: String, userID: String?
  )
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "POST", path: "moderation/automod/message",
      authentication: .either,
      body: { credentials in
        [
          "user_id": try credentials.resolveUserID(
            userID, parameter: "user_id", matchingToken: true),
          "msg_id": messageID,
          "action": action,
        ]
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
  ///   - userID: The acting user; required for app tokens, otherwise defaults to the token’s user.
  ///   - messageID: The identifier of the message.
  public static func approveAutoModMessage(messageID: String, userID: String? = nil)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "ALLOW", userID: userID)
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
  ///   - userID: The acting user; required for app tokens, otherwise defaults to the token’s user.
  ///   - messageID: The identifier of the message.
  public static func denyAutoModMessage(messageID: String, userID: String? = nil)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    self.handleAutoModMessage(messageID: messageID, action: "DENY", userID: userID)
  }
}
