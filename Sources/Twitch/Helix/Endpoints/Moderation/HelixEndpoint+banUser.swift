import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Bans or times out a user in a channel.
  ///
  /// With a user access token, requires `moderator:manage:banned_users`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#ban-user
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - duration: The timeout duration in seconds; `nil` requests a permanent ban.
  ///   - reason: The reason supplied for this action, when provided.
  public static func banUser(
    _ userID: String,
    in broadcasterID: String,
    for duration: Duration? = nil,
    reason: String? = nil
  ) -> HelixEndpoint<Ban, Ban, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "moderation/bans",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      body: { _ in
        BanUserBody(
          userID: userID,
          reason: reason,
          duration: duration)
      },
      makeResponse: {
        let ban = try $0.requireFirst()

        return ban
      })
  }
}

private struct BanUserBody: Encodable, Sendable {
  let userID: String
  let reason: String?
  let duration: Duration?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case reason, duration
  }
}

/// The account and timing information returned after banning or timing out a user.
@MemberwiseInit(.public)
public struct Ban: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The Twitch user ID.
  public let userID: String
  /// The time the resource was created.
  public let createdAt: Date
  /// The scheduled end time, when provided.
  public let endTime: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case userID = "userId"
    case createdAt, endTime
  }
}
