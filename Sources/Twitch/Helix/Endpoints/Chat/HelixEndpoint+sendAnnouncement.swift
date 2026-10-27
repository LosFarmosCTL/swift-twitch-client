import Foundation

extension HelixEndpoint {
  /// Sends an announcement to a channel’s chat.
  ///
  /// With a user access token, requires `moderator:manage:announcements`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-chat-announcement
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - message: The text to send.
  ///   - color: The announcement highlight color; `nil` uses Twitch’s default.
  ///   - isSourceOnly: With an app token, whether to send only to the source channel.
  ///     Leave `nil` for user tokens; Twitch rejects this field with user tokens.
  public static func sendAnnouncement(
    in broadcasterID: String,
    message: String,
    color: AnnouncementColor? = nil,
    isSourceOnly: Bool? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "chat/announcements",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      body: { _ in
        SendAnnouncementRequestBody(
          message: message, color: color, isSourceOnly: isSourceOnly)
      })
  }
}

internal struct SendAnnouncementRequestBody: Encodable, Sendable {
  let message: String
  let color: AnnouncementColor?
  let isSourceOnly: Bool?

  enum CodingKeys: String, CodingKey {
    case message, color
    case isSourceOnly = "forSourceOnly"
  }
}

/// Highlight colors available for chat announcements.
public enum AnnouncementColor: String, Encodable, Sendable {
  /// The blue color option.
  case blue
  /// The green color option.
  case green
  /// The orange color option.
  case orange
  /// The purple color option.
  case purple
  /// The channel’s primary announcement color.
  case primary
}
