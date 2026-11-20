import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Updates a channel’s chat restrictions.
  ///
  /// With a user access token, requires `moderator:manage:chat_settings`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/chat/#update-chat-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The acting moderator; required for app tokens, otherwise defaults to the token’s user.
  ///   - settings: A patch containing the settings to change.
  public static func updateChatSettings(
    of broadcasterID: String,
    moderatorID: String? = nil,
    settings: ChatSettingsUpdate
  ) -> HelixEndpoint<ChatSettings> {
    .init(
      method: "PATCH", path: "chat/settings",
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
      body: { _ in settings },
      responseType: ChatSettings.self,
      makeResponse: { try $0.requireFirst() })
  }
}

/// A partial update to a channel’s chat restrictions.
///
/// For each Boolean, `nil` leaves the setting unchanged, `false` disables it, and
/// `true` enables it. To enable a mode, set its Boolean to `true` and supply any
/// desired duration separately. Twitch validates duration ranges and combinations
/// according to the endpoint reference.
@MemberwiseInit(.public)
public struct ChatSettingsUpdate: Encodable, Sendable {
  /// Whether to enable slow mode.
  @Init(default: nil)
  public var slowMode: Bool?
  /// The interval between messages, in seconds (3–120). Pass `nil` to omit the field.
  @Init(default: nil)
  public var slowModeWaitTime: Int?
  /// Whether to enable follower-only mode.
  @Init(default: nil)
  public var followerMode: Bool?
  /// The required following time, in minutes (0–129600). Pass `nil` to omit the field.
  @Init(default: nil)
  public var followerModeDuration: Int?
  /// Whether to restrict chat to subscribers.
  @Init(default: nil)
  public var subscriberMode: Bool?
  /// Whether to restrict chat to emotes.
  @Init(default: nil)
  public var emoteMode: Bool?
  /// Whether to restrict duplicate messages.
  @Init(default: nil)
  public var uniqueChatMode: Bool?
  /// Whether to delay messages from non-moderators.
  @Init(default: nil)
  public var nonModeratorChatDelay: Bool?
  /// The non-moderator delay, in seconds (2, 4, or 6). Pass `nil` to omit the field.
  @Init(default: nil)
  public var nonModeratorChatDelayDuration: Int?
}
