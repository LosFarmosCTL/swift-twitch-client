import Foundation

extension HelixEndpoint {
  public static func getChannelTeams(
    for broadcasterID: String? = nil
  ) -> HelixEndpoint<[Team], Team, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "teams/channel",
      queryItems: { credentials in
        [("broadcaster_id", broadcasterID ?? credentials.userID)]
      },
      makeResponse: { $0.data })
  }
}
