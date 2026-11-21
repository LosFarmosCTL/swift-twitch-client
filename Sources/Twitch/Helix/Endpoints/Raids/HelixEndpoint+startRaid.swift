import Foundation

extension HelixEndpoint {
  /// Starts a raid.
  ///
  /// With a user access token, requires `channel:manage:raids`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/raids/#start-a-raid
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `from_broadcaster_id`.
  ///
  /// - Parameters:
  ///   - toBroadcasterID: The Twitch user ID of the destination broadcaster.
  public static func startRaid(
    to toBroadcasterID: String
  ) -> HelixEndpoint<PendingRaid> {
    .init(
      method: "POST", path: "raids",
      authentication: .user,
      queryItems: { credentials in
        [
          ("from_broadcaster_id", try credentials.requireUserID(parameter: "from_broadcaster_id")),
          ("to_broadcaster_id", toBroadcasterID),
        ]
      },
      responseType: PendingRaid.self,
      makeResponse: {
        let response = try $0.requireFirst()

        return response
      })
  }
}

/// A raid that has been initiated but has not yet completed.
public struct PendingRaid: Decodable, Sendable {
  /// The time the resource was created.
  public let createdAt: Date
  /// Whether the content is marked as mature.
  public let isMature: Bool

  /// Creates a `PendingRaid` value.
  public init(
    createdAt: Date,
    isMature: Bool
  ) {
    self.createdAt = createdAt
    self.isMature = isMature
  }

  enum CodingKeys: String, CodingKey {
    case createdAt
    case isMature
  }
}
