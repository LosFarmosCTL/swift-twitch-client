import Foundation

extension HelixEndpoint {
  /// Updates a channel’s chat restrictions.
  ///
  /// With a user access token, requires `moderator:manage:chat_settings`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-chat-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The acting moderator; required for app tokens, otherwise defaults to the token’s user.
  ///   - settings: The settings to apply.
  public static func updateChatSettings(
    of broadcasterID: String,
    moderatorID: String? = nil,
    settings: ChatSetting...
  ) -> HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> {
    self.updateChatSettings(
      of: broadcasterID, moderatorID: moderatorID, settings: settings)
  }

  /// Updates a channel’s chat restrictions.
  ///
  /// With a user access token, requires `moderator:manage:chat_settings`. App tokens have
  /// additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-chat-settings
  /// ) for request limits and account requirements.
  ///
  /// App tokens require an explicitly authorized moderator ID.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: The acting moderator; required for app tokens, otherwise defaults to the token’s user.
  ///   - settings: The settings to apply.
  public static func updateChatSettings(
    of broadcasterID: String,
    moderatorID: String? = nil,
    settings: [ChatSetting]
  ) -> HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> {
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
      body: { _ in UpdateChatSettingsRequestBody(settings) },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

/// A chat setting to enable or configure in an update request.
///
/// Supplied settings are enabled in the request. Omitted settings are left out of the
/// request body, so this API does not explicitly disable them. Duration-bearing cases
/// include the configured duration when supplied.
public enum ChatSetting: Equatable, Sendable {
  /// Enables slow mode with an optional wait time in seconds.
  case slowMode(Int? = nil)
  /// Enables follower-only chat with an optional following duration in minutes.
  case followerMode(Int? = nil)
  /// Restricts chat to subscribers.
  case subscriberMode
  /// Restricts chat to emotes.
  case emoteMode
  /// Restricts duplicate chat messages.
  case uniqueChatMode

  /// Enables non-moderator chat delay with an optional delay in seconds.
  case nonModeratorChatDelay(Int? = nil)
}

internal struct UpdateChatSettingsRequestBody: Encodable, Sendable {
  var slowMode: Bool?
  var slowModeWaitTime: Int?
  var followerMode: Bool?
  var followerModeDuration: Int?
  var subscriberMode: Bool?
  var emoteMode: Bool?
  var uniqueChatMode: Bool?

  var nonModeratorChatDelay: Bool?
  var nonModeratorChatDelayDuration: Int?

  init(_ settings: [ChatSetting]) {
    for setting in settings {
      switch setting {
      case .slowMode(let waitTime):
        self.slowMode = true
        self.slowModeWaitTime = waitTime
      case .followerMode(let duration):
        self.followerMode = true
        self.followerModeDuration = duration
      case .subscriberMode: self.subscriberMode = true
      case .emoteMode: self.emoteMode = true
      case .uniqueChatMode: self.uniqueChatMode = true
      case .nonModeratorChatDelay(let duration):
        self.nonModeratorChatDelay = true
        self.nonModeratorChatDelayDuration = duration
      }
    }
  }
}
