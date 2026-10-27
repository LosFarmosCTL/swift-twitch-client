import MemberwiseInit

extension HelixEndpoint {
  /// Warns a viewer, preventing chat interaction until they acknowledge the warning.
  ///
  /// Requires `moderator:manage:warnings`. With a user token, the moderator ID must
  /// match the token’s user. App tokens require a prior grant from the moderator.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#warn-chat-user
  /// ).
  ///
  /// - Parameters:
  ///   - userID: The viewer to warn.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - reason: The warning reason, at most 500 characters.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the user token’s identity.
  ///     Required for app tokens.
  public static func warnChatUser(
    _ userID: String, in broadcasterID: String, reason: String, moderatorID: String? = nil
  ) -> HelixEndpoint<ChatWarning, ChatWarning, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "moderation/warnings",
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
      body: { _ in ["data": ["user_id": userID, "reason": reason]] },
      makeResponse: { try $0.requireFirst() })
  }
}

/// A warning issued to a viewer in a channel.
@MemberwiseInit(.public)
public struct ChatWarning: Decodable, Sendable {
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The warned viewer’s user ID.
  public let userID: String
  /// The acting moderator’s user ID.
  public let moderatorID: String
  /// The warning reason.
  public let reason: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case userID = "userId"
    case moderatorID = "moderatorId"
    case reason
  }
}
