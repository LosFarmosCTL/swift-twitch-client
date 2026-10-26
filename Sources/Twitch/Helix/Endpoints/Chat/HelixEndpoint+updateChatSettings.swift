import Foundation

extension HelixEndpoint {
  public static func updateChatSettings(
    of broadcasterID: String,
    settings: ChatSetting...
  ) -> HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> {
    self.updateChatSettings(of: broadcasterID, settings: settings)
  }

  public static func updateChatSettings(
    of broadcasterID: String,
    settings: [ChatSetting]
  ) -> HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "chat/settings",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      body: { _ in UpdateChatSettingsRequestBody(settings) },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

public enum ChatSetting: Equatable, Sendable {
  case slowMode(Int? = nil)
  case followerMode(Int? = nil)
  case subscriberMode
  case emoteMode
  case uniqueChatMode

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
