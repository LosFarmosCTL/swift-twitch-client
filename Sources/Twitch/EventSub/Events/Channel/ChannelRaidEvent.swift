import MemberwiseInit

/// An EventSub notification delivered when a broadcaster raids another channel.
@MemberwiseInit(.public)
public struct ChannelRaidEvent: Event {
  /// The Twitch user ID of the source broadcaster.
  public let fromBroadcasterID: String
  /// The login name of the source broadcaster.
  public let fromBroadcasterLogin: String
  /// The display name of the source broadcaster.
  public let fromBroadcasterDisplayName: String
  /// The Twitch user ID of the destination broadcaster.
  public let toBroadcasterID: String
  /// The login name of the destination broadcaster.
  public let toBroadcasterLogin: String
  /// The display name of the destination broadcaster.
  public let toBroadcasterDisplayName: String

  /// The viewer count reported by Twitch.
  public let viewers: Int

  enum CodingKeys: String, CodingKey {
    case fromBroadcasterID = "fromBroadcasterUserId"
    case fromBroadcasterLogin = "fromBroadcasterUserLogin"
    case fromBroadcasterDisplayName = "fromBroadcasterUserName"
    case toBroadcasterID = "toBroadcasterUserId"
    case toBroadcasterLogin = "toBroadcasterUserLogin"
    case toBroadcasterDisplayName = "toBroadcasterUserName"
    case viewers
  }
}
