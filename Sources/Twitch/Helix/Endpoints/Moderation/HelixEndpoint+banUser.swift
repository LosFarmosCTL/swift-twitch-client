import Foundation

extension HelixEndpoint {
  /// Bans or times out a user in a channel.
  ///
  /// With a user access token, requires `moderator:manage:banned_users`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#ban-user
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - userID: The Twitch user ID.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - duration: The timeout duration in seconds; `nil` requests a permanent ban.
  ///   - reason: The reason supplied for this action, when provided.
  public static func banUser(
    _ userID: String,
    in broadcasterID: String,
    for duration: Duration? = nil,
    reason: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<Ban> {
    .init(
      method: "POST", path: "moderation/bans",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
        ]
      },
      body: { _ in
        [
          "data": BanUserBody(
            userID: userID,
            reason: reason,
            duration: duration?.components.seconds)
        ]
      },
      responseType: Ban.self,
      makeResponse: {
        let ban = try $0.requireFirst()

        return ban
      })
  }
}

private struct BanUserBody: Encodable, Sendable {
  let userID: String
  let reason: String?
  let duration: Int64?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case reason, duration
  }
}

/// The account and timing information returned after banning or timing out a user.
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

  /// Creates a `Ban` value.
  public init(
    broadcasterID: String,
    moderatorID: String,
    userID: String,
    createdAt: Date,
    endTime: Date? = nil
  ) {
    self.broadcasterID = broadcasterID
    self.moderatorID = moderatorID
    self.userID = userID
    self.createdAt = createdAt
    self.endTime = endTime
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case userID = "userId"
    case createdAt, endTime
  }
}
