import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelRaidEvent: Event {
  public let fromBroadcasterID: String
  public let fromBroadcasterLogin: String
  public let fromBroadcasterDisplayName: String
  public let toBroadcasterID: String
  public let toBroadcasterLogin: String
  public let toBroadcasterDisplayName: String

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
