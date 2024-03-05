import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func addChannelModerator(userID: String) -> Self {
    return .init(
      method: "POST", path: "moderation/moderators",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("user_id", userID),
        ]
      })
  }
}
