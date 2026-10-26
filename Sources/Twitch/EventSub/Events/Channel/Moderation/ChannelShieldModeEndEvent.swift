import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelShieldModeEndEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case endedAt
  }
}
