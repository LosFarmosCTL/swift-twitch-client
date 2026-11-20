import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a broadcaster’s streaming schedule, optionally filtered to specific segments.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/schedule/#get-channel-stream-schedule
  /// ). Twitch lists `utc_offset` as unsupported; this factory does not send it.
  ///
  /// - Parameters:
  ///   - broadcasterID: The schedule owner’s user ID.
  ///   - segmentIDs: Up to 100 segment IDs; an empty array requests all segments.
  ///   - startTime: The time from which to return segments; `nil` uses the current time.
  ///   - limit: The page size, from 1 through 25; `nil` uses Twitch’s default.
  ///   - cursor: The next-page cursor, if any.
  /// - Returns: A schedule and the next-page cursor.
  public static func getChannelStreamSchedule(
    for broadcasterID: String, segmentIDs: [String] = [], startTime: Date? = nil,
    limit: Int? = nil, after cursor: String? = nil
  ) -> HelixEndpoint<ChannelStreamScheduleResponse> {
    .init(
      method: "GET", path: "schedule",
      authentication: .either,
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID),
          ("start_time", startTime?.formatted(.iso8601)),
          ("first", limit.map(String.init)), ("after", cursor),
        ] + segmentIDs.map { ("id", $0) }
      }, responseType: StreamSchedule.self,
      makeResponse: {
        ChannelStreamScheduleResponse(
          schedule: try $0.requireFirst(), cursor: $0.pagination?.cursor)
      })
  }
}

/// A schedule page.
@MemberwiseInit(.public)
public struct ChannelStreamScheduleResponse: Sendable {
  /// The schedule on this page.
  public let schedule: StreamSchedule
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?
}
