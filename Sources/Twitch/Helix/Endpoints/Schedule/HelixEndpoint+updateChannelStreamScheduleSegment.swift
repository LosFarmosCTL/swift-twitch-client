import Foundation

extension HelixEndpoint {
  public static func updateChannelStreamScheduleSegment(
    segmentID: String,
    startTime: Date? = nil,
    duration: Int? = nil,
    categoryID: String? = nil,
    title: String? = nil,
    isCancelled: Bool? = nil,
    timezone: String? = nil,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<StreamSchedule, StreamSchedule, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "schedule/segment",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("id", segmentID),
        ]
      },
      body: { _ in
        UpdateChannelStreamScheduleSegmentRequestBody(
          startTime: startTime,
          duration: duration,
          categoryID: categoryID,
          title: title,
          isCancelled: isCancelled,
          timezone: timezone)
      },
      makeResponse: { response in
        let schedule = try response.requireFirst()

        return schedule
      })
  }
}

// swiftlint:disable:next type_name
private struct UpdateChannelStreamScheduleSegmentRequestBody: Encodable, Sendable {
  let startTime: Date?
  let duration: Int?
  let categoryID: String?
  let title: String?
  let isCancelled: Bool?
  let timezone: String?

  enum CodingKeys: String, CodingKey {
    case startTime
    case duration
    case categoryID
    case title
    case isCancelled = "isCanceled"
    case timezone
  }
}
