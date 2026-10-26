import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Postpones the authenticated broadcaster’s next scheduled ad break.
  ///
  /// With a user access token, requires `channel:manage:ads`. App tokens have additional
  /// grant requirements described in the reference.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#snooze-next-ad
  /// ) for request limits and account requirements.
  public static func snoozeNextAd()
    -> HelixEndpoint<SnoozeResult, SnoozeResult, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "channels/ads/schedule/snooze",
      queryItems: { credentials in [("broadcaster_id", credentials.userID)] },
      makeResponse: { result in
        let response = try result.requireFirst()

        return response
      }
    )
  }
}

/// The next ad time and remaining snoozes after postponing an ad break.
@MemberwiseInit(.public)
public struct SnoozeResult: Decodable, Sendable {
  /// The number of ad snoozes remaining.
  public let snoozeCount: Int
  /// The time ad snoozes become available again.
  public let snoozeRefreshAt: Date
  /// The scheduled start time of the next ad break.
  public let nextAdAt: Date
}
