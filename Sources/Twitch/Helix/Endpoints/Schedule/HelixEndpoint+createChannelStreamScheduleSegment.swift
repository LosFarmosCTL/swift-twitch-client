import Foundation

extension HelixEndpoint {
  /// Adds a broadcast segment to a channel’s schedule.
  ///
  /// With a user access token, requires `channel:manage:schedule`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/schedule/#create-channel-stream-schedule-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - startTime: The scheduled start time.
  ///   - timezone: The IANA time zone identifier for the schedule.
  ///   - duration: The schedule segment duration, in minutes.
  ///   - isRecurring: Whether the schedule segment recurs weekly, when provided.
  ///   - categoryID: The category’s identifier.
  ///   - title: The title shown to viewers, when provided.
  public static func createChannelStreamScheduleSegment(
    startTime: Date,
    timezone: String,
    duration: Int,
    isRecurring: Bool? = nil,
    categoryID: String? = nil,
    title: String? = nil
  ) -> HelixEndpoint<StreamSchedule> {
    .init(
      method: "POST", path: "schedule/segment",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id"))
        ]
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
      responseType: StreamSchedule.self,
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

/// A broadcaster’s scheduled stream segments and vacation settings.
public struct StreamSchedule: Decodable, Sendable {
  /// The stream schedule segments.
  public let segments: [StreamScheduleSegment]
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The vacation schedule settings, when provided.
  public let vacation: StreamScheduleVacation?

  /// Creates a `StreamSchedule` value.
  public init(
    segments: [StreamScheduleSegment] = [],
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    vacation: StreamScheduleVacation? = nil
  ) {
    self.segments = segments
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.vacation = vacation
  }

  enum CodingKeys: String, CodingKey {
    case segments
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case broadcasterLogin
    case vacation
  }
}

/// A scheduled broadcast’s timing, category, title, and recurrence.
public struct StreamScheduleSegment: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The scheduled start time.
  public let startTime: Date
  /// The scheduled end time.
  public let endTime: Date?
  /// The title shown to viewers.
  public let title: String
  /// The end of the schedule cancellation period, when set.
  public let cancelledUntil: Date?
  /// The category details, when provided.
  public let category: StreamScheduleCategory?
  /// Whether the schedule segment recurs weekly.
  public let isRecurring: Bool

  /// Creates a `StreamScheduleSegment` value.
  public init(
    id: String,
    startTime: Date,
    endTime: Date? = nil,
    title: String,
    cancelledUntil: Date? = nil,
    category: StreamScheduleCategory? = nil,
    isRecurring: Bool
  ) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.title = title
    self.cancelledUntil = cancelledUntil
    self.category = category
    self.isRecurring = isRecurring
  }

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

/// The Twitch category assigned to a scheduled stream segment.
public struct StreamScheduleCategory: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String

  /// Creates a `StreamScheduleCategory` value.
  public init(
    id: String,
    name: String
  ) {
    self.id = id
    self.name = name
  }
}

/// The period during which a broadcaster’s schedule is on vacation.
public struct StreamScheduleVacation: Decodable, Sendable {
  /// The scheduled start time.
  public let startTime: Date
  /// The scheduled end time.
  public let endTime: Date

  /// Creates a `StreamScheduleVacation` value.
  public init(
    startTime: Date,
    endTime: Date
  ) {
    self.startTime = startTime
    self.endTime = endTime
  }
}
