import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s ad schedule.
  ///
  /// With a user access token, requires `channel:read:ads`. App tokens have additional
  /// grant requirements described in the reference.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-ad-schedule
  /// ) for request limits and account requirements.
  /// - Parameter broadcasterID: The acting user ID. Required with app tokens; otherwise
  ///   defaults to the user token’s identity.
  public static func getAdSchedule(broadcasterID: String? = nil)
    -> HelixEndpoint<[AdSchedule], AdSchedule, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/ads",
      authentication: .either,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(
              broadcasterID, parameter: "broadcaster_id", matchingToken: true)
          )
        ]
      },
      makeResponse: { $0.data }
    )
  }
}

/// The next ad break, recent ad timing, and remaining snooze allowance.
@MemberwiseInit(.public)
public struct AdSchedule: Decodable, Sendable {
  /// The next ad start time, or `nil` when Twitch returns zero.
  public let nextAdAt: Date?
  /// The most recent ad start time, or `nil` when Twitch returns zero.
  public let lastAdAt: Date?
  /// The scheduled ad break duration, in seconds.
  public let duration: Int
  /// The number of seconds of preroll-free viewing remaining.
  public let prerollFreeTime: Int
  /// The number of ad snoozes remaining.
  public let snoozeCount: Int
  /// When snoozes become available again, or `nil` when Twitch returns zero.
  public let snoozeRefreshAt: Date?

  enum CodingKeys: String, CodingKey {
    case nextAdAt, lastAdAt, duration, prerollFreeTime, snoozeCount, snoozeRefreshAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.nextAdAt = try container.decodeAdDate(forKey: .nextAdAt)
    self.lastAdAt = try container.decodeAdDate(forKey: .lastAdAt)
    self.duration = try container.decode(Int.self, forKey: .duration)
    self.prerollFreeTime = try container.decode(Int.self, forKey: .prerollFreeTime)
    self.snoozeCount = try container.decode(Int.self, forKey: .snoozeCount)
    self.snoozeRefreshAt = try container.decodeAdDate(forKey: .snoozeRefreshAt)
  }
}
