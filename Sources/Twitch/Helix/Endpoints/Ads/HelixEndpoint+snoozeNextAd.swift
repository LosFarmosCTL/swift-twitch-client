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
  /// - Parameter broadcasterID: The acting user ID. Required with app tokens; otherwise
  ///   defaults to the user token’s identity.
  public static func snoozeNextAd(broadcasterID: String? = nil)
    -> HelixEndpoint<SnoozeResult, SnoozeResult, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "channels/ads/schedule/snooze",
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
  /// When snoozes become available again, or `nil` when Twitch returns zero.
  public let snoozeRefreshAt: Date?
  /// The next ad start time, or `nil` when Twitch returns zero.
  public let nextAdAt: Date?

  enum CodingKeys: String, CodingKey {
    case snoozeCount, snoozeRefreshAt, nextAdAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.snoozeCount = try container.decode(Int.self, forKey: .snoozeCount)
    self.snoozeRefreshAt = try container.decodeAdDate(forKey: .snoozeRefreshAt)
    self.nextAdAt = try container.decodeAdDate(forKey: .nextAdAt)
  }
}
