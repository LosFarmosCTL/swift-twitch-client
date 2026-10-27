import Foundation

extension HelixEndpoint {
  /// Gets a broadcaster’s streaming schedule, optionally filtered to specific segments.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-stream-schedule
  /// ). Twitch lists `utc_offset` as unsupported; this factory does not send it.
  ///
  /// - Parameters:
  ///   - broadcasterID: The schedule owner’s user ID.
  ///   - segmentIDs: Up to 100 segment IDs; an empty array requests all segments.
  ///   - startTime: The time from which to return segments; `nil` uses the current time.
  ///   - limit: The page size, from 1 through 25; `nil` uses Twitch’s default.
  ///   - afterCursor: The next-page cursor, if any.
  /// - Returns: A schedule and the next-page cursor.
  public static func getChannelStreamSchedule(
    for broadcasterID: String, segmentIDs: [String] = [], startTime: Date? = nil,
    limit: Int? = nil, after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (schedule: StreamSchedule, cursor: String?), StreamSchedule,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "schedule",
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID),
          ("start_time", startTime?.formatted(.iso8601)),
          ("first", limit.map(String.init)), ("after", afterCursor),
        ] + segmentIDs.map { ("id", $0) }
      }, makeResponse: { (try $0.requireFirst(), $0.pagination?.cursor) })
  }
}
