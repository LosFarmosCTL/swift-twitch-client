import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == StreamSchedule,
  HelixResponseType == StreamSchedule
{
  public static func updateChannelStreamScheduleSegment(
    segmentID: String,
    startTime: Date? = nil,
    duration: Int? = nil,
    categoryID: String? = nil,
    title: String? = nil,
    isCanceled: Bool? = nil,
    timezone: String? = nil,
    broadcasterID: String? = nil
  ) -> Self {
    return .init(
      method: "PATCH", path: "schedule/segment",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("id", segmentID),
        ]
      },
      body: { _ in
        UpdateChannelStreamScheduleSegmentRequestBody(
          startTime: startTime,
          duration: duration,
          categoryID: categoryID,
          title: title,
          isCanceled: isCanceled,
          timezone: timezone)
      },
      makeResponse: { response in
        guard let schedule = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

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
  let isCanceled: Bool?
  let timezone: String?
}
