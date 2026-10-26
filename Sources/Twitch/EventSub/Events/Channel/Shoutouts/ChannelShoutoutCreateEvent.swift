import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelShoutoutCreateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let toBroadcasterID: String
  public let toBroadcasterLogin: String
  public let toBroadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let viewerCount: Int
  public let startedAt: Date
  public let cooldownEndsAt: Date
  public let targetCooldownEndsAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case toBroadcasterID = "toBroadcasterUserId"
    case toBroadcasterLogin = "toBroadcasterUserLogin"
    case toBroadcasterDisplayName = "toBroadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case viewerCount
    case startedAt
    case cooldownEndsAt
    case targetCooldownEndsAt
  }
}
