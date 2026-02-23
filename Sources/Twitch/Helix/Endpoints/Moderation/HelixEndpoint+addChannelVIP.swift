import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse,
  HelixResponseType == EmptyResponse
{
  public static func addChannelVIP(userID: String) -> Self {
    return .init(
      method: "POST", path: "channels/vips",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("user_id", userID),
        ]
      })
  }
}
