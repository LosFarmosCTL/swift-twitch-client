import Foundation

extension HelixEndpoint {
  public static func getChannelTeams(
    for broadcasterID: String? = nil
  ) -> HelixEndpoint<[Team], Team, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "teams/channel",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      makeResponse: { $0.data })
  }
}
