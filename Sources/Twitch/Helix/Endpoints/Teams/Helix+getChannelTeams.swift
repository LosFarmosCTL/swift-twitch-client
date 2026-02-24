import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Team], HelixResponseType == Team
{
  public static func getChannelTeams(for broadcasterID: String? = nil) -> Self {
    return .init(
      method: "GET", path: "teams/channel",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      makeResponse: { $0.data })
  }
}
