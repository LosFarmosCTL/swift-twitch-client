import Foundation

extension HelixEndpoint {
  /// Deletes a broadcast segment from a channel’s schedule.
  ///
  /// With a user access token, requires `channel:manage:schedule`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/schedule/#delete-channel-stream-schedule-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameter segmentID: The identifier of the segment.
  public static func deleteChannelStreamScheduleSegment(
    segmentID: String
  ) -> HelixEndpoint<Void> {
    .init(
      method: "DELETE", path: "schedule/segment",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("id", segmentID),
        ]
      })
  }
}
