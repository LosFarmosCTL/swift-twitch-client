import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Starts a raid.
  ///
  /// With a user access token, requires `channel:manage:raids`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#start-a-raid
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `from_broadcaster_id`.
  ///
  /// - Parameters:
  ///   - toBroadcasterID: The Twitch user ID of the destination broadcaster.
  public static func startRaid(
    to toBroadcasterID: String
  ) -> HelixEndpoint<PendingRaid, PendingRaid, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "raids",
      queryItems: { credentials in
        [
          ("from_broadcaster_id", credentials.userID),
          ("to_broadcaster_id", toBroadcasterID),
        ]
      },
      makeResponse: {
        let response = try $0.requireFirst()

        return response
      })
  }
}

/// A raid that has been initiated but has not yet completed.
@MemberwiseInit(.public)
public struct PendingRaid: Decodable, Sendable {
  /// The time the resource was created.
  public let createdAt: Date
  /// Whether the content is marked as mature.
  public let isMature: Bool

  enum CodingKeys: String, CodingKey {
    case createdAt
    case isMature
  }
}
