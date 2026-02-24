import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteChatMessage(
    in channel: String, messageID: String
  ) -> Self {
    return .init(
      method: "DELETE", path: "moderation/chat",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("message_id", messageID),
        ]
      })
  }
}
