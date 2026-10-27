import Foundation

extension HelixEndpoint {
  /// Gets live streams from channels the authenticated user follows.
  ///
  /// With a user access token, requires `user:read:follows`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-followed-streams
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(streams: [Stream], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getFollowedStreams(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (streams: [Stream], cursor: String?),
    Stream, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "streams/followed",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
