import Foundation

extension HelixEndpoint {
  /// Deletes videos owned by the authenticated broadcaster.
  ///
  /// With a user access token, requires `channel:manage:videos`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-videos
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - videoIDs: The video IDs to include in the request.
  public static func deleteVideos(
    videoIDs: [String]
  ) -> HelixEndpoint<[String], String, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "DELETE", path: "videos",
      queryItems: { _ in
        videoIDs.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}
