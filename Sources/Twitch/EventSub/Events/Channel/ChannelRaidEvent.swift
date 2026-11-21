/// An EventSub notification delivered when a broadcaster raids another channel.
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

  /// Creates a `ChannelRaidEvent` value.
  public init(
    fromBroadcasterID: String,
    fromBroadcasterLogin: String,
    fromBroadcasterDisplayName: String,
    toBroadcasterID: String,
    toBroadcasterLogin: String,
    toBroadcasterDisplayName: String,
    viewers: Int
  ) {
    self.fromBroadcasterID = fromBroadcasterID
    self.fromBroadcasterLogin = fromBroadcasterLogin
    self.fromBroadcasterDisplayName = fromBroadcasterDisplayName
    self.toBroadcasterID = toBroadcasterID
    self.toBroadcasterLogin = toBroadcasterLogin
    self.toBroadcasterDisplayName = toBroadcasterDisplayName
    self.viewers = viewers
  }

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
