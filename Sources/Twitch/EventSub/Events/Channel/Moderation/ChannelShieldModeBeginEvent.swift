import Foundation

public struct ChannelShieldModeBeginEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case startedAt
  }
}
