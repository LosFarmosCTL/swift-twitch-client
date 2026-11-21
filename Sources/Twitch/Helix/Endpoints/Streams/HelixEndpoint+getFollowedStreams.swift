import Foundation

extension HelixEndpoint {
  /// Gets live streams from channels the authenticated user follows.
  ///
  /// With a user access token, requires `user:read:follows`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/streams/#get-followed-streams
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields ``FollowedStreamsResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getFollowedStreams(
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<FollowedStreamsResponse> {
    .init(
      method: "GET", path: "streams/followed",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUserID(parameter: "user_id")),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, responseType: Stream.self,
      makeResponse: {
        FollowedStreamsResponse(streams: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A page of followed streams.
public struct FollowedStreamsResponse: Sendable {
  /// The streams on this page.
  public let streams: [Stream]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `FollowedStreamsResponse` value.
  public init(
    streams: [Stream] = [],
    cursor: String? = nil
  ) {
    self.streams = streams
    self.cursor = cursor
  }
}
