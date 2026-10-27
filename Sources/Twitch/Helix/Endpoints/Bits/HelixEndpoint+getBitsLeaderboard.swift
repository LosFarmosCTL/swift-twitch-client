import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s Bits leaderboard.
  ///
  /// With a user access token, requires `bits:read`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-bits-leaderboard
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - count: The maximum number of ranked users to return, from 1 to 100; `nil` uses
  ///     10.
  ///   - period: The reporting period.
  ///   - startedAt: A date selecting the calendar period to aggregate in Twitch’s PST
  ///     time zone; it is ignored for `.all`. Required for other periods.
  ///   - userID: The Twitch user ID, when provided.
  public static func getBitsLeaderboard(
    count: Int? = nil,
    period: BitsLeaderboardPeriod? = nil,
    startedAt: Date? = nil,
    userID: String? = nil
  ) -> HelixEndpoint<
    BitsLeaderboard, BitsLeaderboardEntry, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "bits/leaderboard",
      authentication: .user,
      queryItems: { _ in
        [
          ("count", count.map(String.init)),
          ("period", period?.rawValue),
          ("started_at", startedAt?.formatted(.iso8601)),
          ("user_id", userID),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return BitsLeaderboard(
          leaders: $0.data,
          total: total,
          startDate: $0.dateRange?.startedAt,
          endDate: $0.dateRange?.endedAt)
      })
  }
}

/// The calendar period over which to aggregate a broadcaster’s Bits leaderboard.
public enum BitsLeaderboardPeriod: String, Sendable {
  /// A one-day reporting period.
  case day
  /// A one-week reporting period.
  case week
  /// A one-month reporting period.
  case month
  /// A one-year reporting period.
  case year
  /// The entire available reporting period.
  case all
}

/// The top cheering users and the reporting period used to rank them.
public struct BitsLeaderboard: Sendable {
  /// The users ranked by the number of Bits they cheered, highest first.
  public let leaders: [BitsLeaderboardEntry]
  /// The number of returned ranked users, capped by the requested `count`. This endpoint
  /// does not provide pagination or an overall leaderboard count.
  public let total: Int
  /// The beginning of the date range, when provided.
  public let startDate: Date?
  /// The end of the date range, when provided.
  public let endDate: Date?
}

/// A user’s rank and contribution total on a Bits leaderboard.
@MemberwiseInit(.public)
public struct BitsLeaderboardEntry: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The one-based position in the leaderboard.
  public let rank: Int
  /// The number of Bits the user cheered during the reporting period.
  public let score: Int

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case rank
    case score
  }
}
