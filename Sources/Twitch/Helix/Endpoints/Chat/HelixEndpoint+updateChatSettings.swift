import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChatSettings, HelixResponseType == ChatSettings
{
  public static func updateChatSettings(
    of channel: String, _ chatModes: ChatSetting...
  ) -> Self {
    return self.updateChatSettings(
      broadcasterID: channel, chatModes)
  }

  public static func updateChatSettings(
    broadcasterID: String, _ chatModes: [ChatSetting]
  ) -> Self {
    return .init(
      method: "PATCH", path: "chat/settings",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", auth.userID),
        ]
      },
      body: { _ in
        UpdateChatSettingsRequestBody(chatModes)
      },
      makeResponse: {
        guard let settings = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

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
