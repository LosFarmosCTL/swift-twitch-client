public struct ChannelSuspiciousUserUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let moderatorID: String
  public let moderatorName: String
  public let moderatorLogin: String

  public let userID: String
  public let userName: String
  public let userLogin: String

  public let lowTrustStatus: ChannelSuspiciousUserMessageEvent.LowTrustStatus

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case moderatorID = "moderatorUserId"
    case moderatorName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"

    case userID = "userId"
    case userName, userLogin

    case lowTrustStatus
  }
}
