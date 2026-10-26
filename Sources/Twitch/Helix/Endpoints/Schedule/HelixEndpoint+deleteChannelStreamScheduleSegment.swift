import Foundation

extension HelixEndpoint {
  /// Deletes a broadcast segment from a channel’s schedule.
  ///
  /// With a user access token, requires `channel:manage:schedule`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-channel-stream-schedule-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - segmentID: The identifier of the segment.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func deleteChannelStreamScheduleSegment(
    segmentID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "schedule/segment",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("id", segmentID),
        ]
      })
  }
}
