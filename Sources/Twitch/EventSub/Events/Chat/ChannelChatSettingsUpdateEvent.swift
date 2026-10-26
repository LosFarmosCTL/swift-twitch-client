import MemberwiseInit

/// An EventSub notification delivered when a channel’s chat settings change.
@MemberwiseInit(.public)
public struct ChannelChatSettingsUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// Whether chat is restricted to emotes.
  public let emoteMode: Bool
  /// Whether chat is restricted to subscribers.
  public let subscriberMode: Bool
  /// Whether duplicate chat messages are restricted.
  public let uniqueChatMode: Bool

  /// The minimum time a viewer must follow before chatting; `nil` disables follower-only
  /// mode.
  public let followerMode: Duration?
  /// The minimum interval between a viewer’s messages; `nil` disables slow mode.
  public let slowMode: Duration?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case emoteMode
    case followerMode
    case followerModeDurationMinutes
    case slowMode
    case slowModeWaitTimeSeconds
    case subscriberMode
    case uniqueChatMode
  }

  /// Decodes chat settings, converting enabled follower and slow modes to durations and
  /// disabled modes to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    self.broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)

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
