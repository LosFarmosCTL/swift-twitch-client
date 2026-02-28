import Foundation

extension HelixEndpoint {
  public static func updateChannelStreamSchedule(
    isVacationEnabled: Bool? = nil,
    vacationStartTime: Date? = nil,
    vacationEndTime: Date? = nil,
    timezone: String? = nil,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "schedule/settings",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("is_vacation_enabled", isVacationEnabled.map(String.init)),
          ("vacation_start_time", vacationStartTime?.formatted(.iso8601)),
          ("vacation_end_time", vacationEndTime?.formatted(.iso8601)),
          ("timezone", timezone),
        ]
      })
  }
}
