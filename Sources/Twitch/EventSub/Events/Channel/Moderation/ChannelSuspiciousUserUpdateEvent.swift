import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelSuspiciousUserUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let moderatorID: String
  public let moderatorDisplayName: String
  public let moderatorLogin: String

  public let userID: String
  public let userDisplayName: String
  public let userLogin: String

  public let lowTrustStatus: ChannelSuspiciousUserMessageEvent.LowTrustStatus

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case moderatorID = "moderatorUserId"
    case moderatorDisplayName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case lowTrustStatus
  }
}
