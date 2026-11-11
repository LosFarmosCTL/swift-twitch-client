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

/// A chat setting to enable, configure, or disable in an update request.
///
/// Omitted settings are left out of the request body. Use `disable` to explicitly turn
/// a mode off. If a mode appears more than once, the last setting wins.
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

  /// Explicitly disables a mode, without sending its duration.
  case disable(Mode)

  /// The chat restrictions that may be explicitly disabled.
  public enum Mode: Equatable, Sendable {
    case slowMode
    case followerMode
    case subscriberMode
    case emoteMode
    case uniqueChatMode
    case nonModeratorChatDelay
  }
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
      case .disable(let mode):
        switch mode {
        case .slowMode:
          self.slowMode = false
          self.slowModeWaitTime = nil
        case .followerMode:
          self.followerMode = false
          self.followerModeDuration = nil
        case .subscriberMode: self.subscriberMode = false
        case .emoteMode: self.emoteMode = false
        case .uniqueChatMode: self.uniqueChatMode = false
        case .nonModeratorChatDelay:
          self.nonModeratorChatDelay = false
          self.nonModeratorChatDelayDuration = nil
        }
      }
    }
  }
}
