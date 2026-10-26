import Foundation

extension HelixEndpoint {
  /// Adds a user to the authenticated user’s block list.
  ///
  /// With a user access token, requires `user:manage:blocked_users`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#block-user
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The Twitch user ID.
  ///   - sourceContext: The context in which the block originated; `nil` omits it.
  ///   - reason: The reason supplied for this action, when provided.
  public static func blockUser(
    _ userID: String,
    sourceContext: UserBlockSourceContext? = nil,
    reason: UserBlockReason? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "users/blocks",
      queryItems: { _ in
        [
          ("target_user_id", userID),
          ("source_context", sourceContext?.rawValue),
          ("reason", reason?.rawValue),
        ]
      })
  }
}

/// The context in which a user block originated.
public enum UserBlockSourceContext: String, Decodable, Sendable {
  /// The action originated in chat.
  case chat
  /// The action originated in whispers.
  case whisper
}

/// The reason for blocking a user.
public enum UserBlockReason: String, Decodable, Sendable {
  /// Blocks the user for harassment.
  case harassment
  /// Blocks the user for spam.
  case spam
  /// Blocks the user for another reason.
  case other
}
