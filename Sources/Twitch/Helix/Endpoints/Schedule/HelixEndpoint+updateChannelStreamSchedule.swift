import Foundation

extension HelixEndpoint {
  /// Updates a channel’s schedule vacation settings.
  ///
  /// With a user access token, requires `channel:manage:schedule`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-channel-stream-schedule
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - isVacationEnabled: Whether to enable vacation mode.
  ///   - vacationStartTime: The start of the vacation period.
  ///   - vacationEndTime: The end of the vacation period.
  ///   - timezone: The IANA time zone identifier for the schedule.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func updateChannelStreamSchedule(
    isVacationEnabled: Bool? = nil,
    vacationStartTime: Date? = nil,
    vacationEndTime: Date? = nil,
    timezone: String? = nil,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "schedule/settings",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("is_vacation_enabled", isVacationEnabled.map(String.init)),
          ("vacation_start_time", vacationStartTime?.formatted(.iso8601)),
          ("vacation_end_time", vacationEndTime?.formatted(.iso8601)),
          ("timezone", timezone),
        ]
      })
  }
}
