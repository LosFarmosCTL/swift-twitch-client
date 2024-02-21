import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<ChatSettings> {
  public static func updateChatSettings(
    broadcasterId: String, moderatorId: String, _ chatModes: ChatSetting...
  ) -> Self {
    return self.updateChatSettings(
      broadcasterId: broadcasterId, moderatorId: moderatorId, chatModes)
  }

  public static func updateChatSettings(
    broadcasterId: String, moderatorId: String, _ chatModes: [ChatSetting]
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("moderator_id", moderatorId))

    let body = UpdateChatSettingsRequestBody(chatModes)

    return .init(
      method: "PATCH", path: "chat/settings", queryItems: queryItems, body: body)
  }
}

public enum ChatSetting: Equatable {
  case slowMode(Int? = nil)
  case followerMode(Int? = nil)
  case subscriberMode
  case emoteMode
  case uniqueChatMode

  case nonModeratorChatDelay(Int? = nil)
}

internal struct UpdateChatSettingsRequestBody: Encodable {
  var slowMode: Bool?
  var slowModeWaitTime: Int?
  var followerMode: Bool?
  var followerModeDuration: Int?
  var subscriberMode: Bool?
  var emoteMode: Bool?
  var uniqueChatMode: Bool?

  var nonModeratorChatDelay: Bool?
  var nonModeratorChatDelayDuration: Int?

  enum CodingKeys: String, CodingKey {
    case slowMode = "slow_mode"
    case slowModeWaitTime = "slow_mode_wait_time"
    case followerMode = "follower_mode"
    case followerModeDuration = "follower_mode_duration"
    case subscriberMode = "subscriber_mode"
    case emoteMode = "emote_mode"
    case uniqueChatMode = "unique_chat_mode"

    case nonModeratorChatDelay = "non_moderator_chat_delay"
    case nonModeratorChatDelayDuration = "non_moderator_chat_delay_duration"
  }

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
