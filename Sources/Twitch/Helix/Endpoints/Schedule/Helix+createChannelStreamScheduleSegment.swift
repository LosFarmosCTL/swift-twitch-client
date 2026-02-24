import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == StreamSchedule,
  HelixResponseType == StreamSchedule
{
  public static func createChannelStreamScheduleSegment(
    startTime: Date,
    timezone: String,
    duration: Int,
    isRecurring: Bool? = nil,
    categoryID: String? = nil,
    title: String? = nil,
    broadcasterID: UserID? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "schedule/segment",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      body: { _ in
        CreateChannelStreamScheduleSegmentRequestBody(
          startTime: startTime,
          timezone: timezone,
          duration: duration,
          isRecurring: isRecurring,
          categoryID: categoryID,
          title: title)
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
private struct CreateChannelStreamScheduleSegmentRequestBody: Encodable, Sendable {
  let startTime: Date
  let timezone: String
  let duration: Int
  let isRecurring: Bool?
  let categoryID: String?
  let title: String?
}

public struct StreamSchedule: Decodable, Sendable {
  public let segments: [StreamScheduleSegment]
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String
  public let vacation: StreamScheduleVacation?

  enum CodingKeys: String, CodingKey {
    case segments
    case broadcasterID = "broadcasterId"
    case broadcasterName, broadcasterLogin
    case vacation
  }
}

public struct StreamScheduleSegment: Decodable, Sendable {
  public let id: String
  public let startTime: Date
  public let endTime: Date
  public let title: String
  public let canceledUntil: Date?
  public let category: StreamScheduleCategory?
  public let isRecurring: Bool
}

public struct StreamScheduleCategory: Decodable, Sendable {
  public let id: String
  public let name: String
}

public struct StreamScheduleVacation: Decodable, Sendable {
  public let startTime: Date
  public let endTime: Date
}
