import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func createChannelStreamScheduleSegment(
    startTime: Date,
    timezone: String,
    duration: Int,
    isRecurring: Bool? = nil,
    categoryID: String? = nil,
    title: String? = nil,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<StreamSchedule, StreamSchedule, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "schedule/segment",
      queryItems: { credentials in
        [("broadcaster_id", broadcasterID ?? credentials.userID)]
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
        let schedule = try response.requireFirst()

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

@MemberwiseInit(.public)
public struct StreamSchedule: Decodable, Sendable {
  public let segments: [StreamScheduleSegment]
  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String
  public let vacation: StreamScheduleVacation?

  enum CodingKeys: String, CodingKey {
    case segments
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case broadcasterLogin
    case vacation
  }
}

@MemberwiseInit(.public)
public struct StreamScheduleSegment: Decodable, Sendable {
  public let id: String
  public let startTime: Date
  public let endTime: Date
  public let title: String
  public let cancelledUntil: Date?
  public let category: StreamScheduleCategory?
  public let isRecurring: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case startTime
    case endTime
    case title
    case cancelledUntil = "canceledUntil"
    case category
    case isRecurring
  }
}

@MemberwiseInit(.public)
public struct StreamScheduleCategory: Decodable, Sendable {
  public let id: String
  public let name: String
}

@MemberwiseInit(.public)
public struct StreamScheduleVacation: Decodable, Sendable {
  public let startTime: Date
  public let endTime: Date
}
