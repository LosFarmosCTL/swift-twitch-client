public struct ChannelRaidEvent: Event {
  public let fromBroadcasterID: String
  public let fromBroadcasterLogin: String
  public let fromBroadcasterName: String
  public let toBroadcasterID: String
  public let toBroadcasterLogin: String
  public let toBroadcasterName: String

  public let viewers: Int

  enum CodingKeys: String, CodingKey {
    case fromBroadcasterID = "fromBroadcasterUserId"
    case fromBroadcasterLogin = "fromBroadcasterUserLogin"
    case fromBroadcasterName = "fromBroadcasterUserName"
    case toBroadcasterID = "toBroadcasterUserId"
    case toBroadcasterLogin = "toBroadcasterUserLogin"
    case toBroadcasterName = "toBroadcasterUserName"

    case viewers
  }
}
