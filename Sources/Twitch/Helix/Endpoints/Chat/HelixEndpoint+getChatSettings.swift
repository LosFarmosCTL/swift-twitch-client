import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChatSettings, HelixResponseType == ChatSettings
{
  public static func getChatSettings(
    of channel: UserID, moderatorID: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "chat/settings",
      queryItems: { _ in
        [("broadcaster_id", channel), ("moderator_id", moderatorID)]
      },
      makeResponse: {
        guard let settings = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return settings
      })
  }
}

public struct ChatSettings: Decodable {
  public let broadcasterID: String
  public let slowModeWaitTime: Int?
  public let followerModeDuration: Int?
  public let subscriberMode: Bool
  public let emoteMode: Bool
  public let uniqueChatMode: Bool

  public let nonModeratorChatDelay: Int?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case slowModeWaitTime
    case followerModeDuration
    case subscriberMode
    case emoteMode
    case uniqueChatMode

    case nonModeratorChatDelayDuration
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
