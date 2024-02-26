import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<ChatSettings> {
  public static func getChatSettings(
    of channel: UserID, moderatorID: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("moderator_id", moderatorID))

    return .init(method: "GET", path: "chat/settings", queryItems: queryItems)
  }
}

public struct ChatSettings: Decodable {
  let broadcasterID: String
  let slowModeWaitTime: Int?
  let followerModeDuration: Int?
  let subscriberMode: Bool
  let emoteMode: Bool
  let uniqueChatMode: Bool

  let nonModeratorChatDelay: Int?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case slowModeWaitTime = "slow_mode_wait_time"
    case followerModeDuration = "follower_mode_duration"
    case subscriberMode = "subscriber_mode"
    case emoteMode = "emote_mode"
    case uniqueChatMode = "unique_chat_mode"

    case nonModeratorChatDelayDuration = "non_moderator_chat_delay_duration"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.slowModeWaitTime = try container.decodeIfPresent(
      Int.self, forKey: .slowModeWaitTime)
    self.followerModeDuration = try container.decodeIfPresent(
      Int.self, forKey: .followerModeDuration)

    self.subscriberMode = try container.decode(Bool.self, forKey: .subscriberMode)
    self.emoteMode = try container.decode(Bool.self, forKey: .emoteMode)
    self.uniqueChatMode = try container.decode(Bool.self, forKey: .uniqueChatMode)

    self.nonModeratorChatDelay = try container.decodeIfPresent(
      Int.self, forKey: .nonModeratorChatDelayDuration)
  }
}
