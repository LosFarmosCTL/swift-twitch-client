public struct ChannelChatSettingsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let emoteMode: Bool
  public let subscriberMode: Bool
  public let uniqueChatMode: Bool

  public let followerMode: Duration?
  public let slowMode: Duration?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case emoteMode, followerMode, followerModeDurationMinutes, slowMode,
      slowModeWaitTimeSeconds, subscriberMode, uniqueChatMode
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    self.broadcasterName = try container.decode(String.self, forKey: .broadcasterName)

    self.emoteMode = try container.decode(Bool.self, forKey: .emoteMode)
    self.subscriberMode = try container.decode(Bool.self, forKey: .subscriberMode)
    self.uniqueChatMode = try container.decode(Bool.self, forKey: .uniqueChatMode)

    let followerMode = try container.decode(Bool.self, forKey: .followerMode)
    if followerMode {
      let duration = try container.decode(Int.self, forKey: .followerModeDurationMinutes)
      self.followerMode = .seconds(duration * 60)
    } else {
      self.followerMode = nil
    }

    let slowMode = try container.decode(Bool.self, forKey: .slowMode)
    if slowMode {
      let waitTime = try container.decode(Int.self, forKey: .slowModeWaitTimeSeconds)
      self.slowMode = .seconds(waitTime)
    } else {
      self.slowMode = nil
    }
  }
}
