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
  /// The scheduled start time of the next ad break.
  public let nextAdAt: Date
  /// The start time of the most recent ad break.
  public let lastAdAt: Date
  /// The scheduled ad break duration, in seconds.
  public let duration: Int
  /// The number of seconds of preroll-free viewing remaining.
  public let prerollFreeTime: Int
  /// The number of ad snoozes remaining.
  public let snoozeCount: Int
  /// The time ad snoozes become available again.
  public let snoozeRefreshAt: Date
}
