import Foundation

public struct ChannelShoutoutCreateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let toBroadcasterID: String
  public let toBroadcasterLogin: String
  public let toBroadcasterName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let viewerCount: Int
  public let startedAt: Date
  public let cooldownEndsAt: Date
  public let targetCooldownEndsAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case toBroadcasterID = "toBroadcasterUserId"
    case toBroadcasterLogin = "toBroadcasterUserLogin"
    case toBroadcasterName = "toBroadcasterUserName"

    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case viewerCount
    case startedAt, cooldownEndsAt, targetCooldownEndsAt
  }
}
