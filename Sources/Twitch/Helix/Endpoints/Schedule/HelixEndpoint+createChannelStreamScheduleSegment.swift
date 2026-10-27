import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Adds a broadcast segment to a channel’s schedule.
  ///
  /// With a user access token, requires `channel:manage:schedule`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-channel-stream-schedule-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - startTime: The scheduled start time.
  ///   - timezone: The IANA time zone identifier for the schedule.
  ///   - duration: The schedule segment duration, in minutes.
  ///   - isRecurring: Whether the schedule segment recurs weekly, when provided.
  ///   - categoryID: The category’s identifier.
  ///   - title: The title shown to viewers, when provided.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
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
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          )
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
@MemberwiseInit(.public)
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

  enum CodingKeys: String, CodingKey {
    case segments
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case broadcasterLogin
    case vacation
  }
}

/// A scheduled broadcast’s timing, category, title, and recurrence.
@MemberwiseInit(.public)
public struct StreamScheduleSegment: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The scheduled start time.
  public let startTime: Date
  /// The scheduled end time.
  public let endTime: Date
  /// The title shown to viewers.
  public let title: String
  /// The end of the schedule cancellation period, when set.
  public let cancelledUntil: Date?
  /// The category details, when provided.
  public let category: StreamScheduleCategory?
  /// Whether the schedule segment recurs weekly.
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

/// The Twitch category assigned to a scheduled stream segment.
@MemberwiseInit(.public)
public struct StreamScheduleCategory: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
}

/// The period during which a broadcaster’s schedule is on vacation.
@MemberwiseInit(.public)
public struct StreamScheduleVacation: Decodable, Sendable {
  /// The scheduled start time.
  public let startTime: Date
  /// The scheduled end time.
  public let endTime: Date
}
