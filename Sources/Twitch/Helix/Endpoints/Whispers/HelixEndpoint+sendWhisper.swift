import Foundation

extension HelixEndpoint {
  /// Sends a whisper as the authenticated user.
  ///
  /// With a user access token, requires `user:manage:whispers`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-whisper
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `from_user_id`.
  ///
  /// - Parameters:
  ///   - toUserID: The Twitch user ID of the receiving user.
  ///   - message: The text to send.
  public static func sendWhisper(
    to toUserID: String,
    message: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "whispers",
      queryItems: { credentials in
        [
          ("from_user_id", credentials.userID),
          ("to_user_id", toUserID),
        ]
      },
      body: { _ in Whisper(message: message) })
  }
}

internal struct Whisper: Encodable, Sendable { let message: String }
