import Foundation

extension HelixEndpoint {
  /// Gets the teams a broadcaster belongs to.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-teams
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  /// App tokens require an explicit target ID.
  public static func getChannelTeams(
    for broadcasterID: String? = nil
  ) -> HelixEndpoint<[Team], Team, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "teams/channel",
      authentication: .either,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          )
        ]
      },
      makeResponse: { $0.data })
  }
}
