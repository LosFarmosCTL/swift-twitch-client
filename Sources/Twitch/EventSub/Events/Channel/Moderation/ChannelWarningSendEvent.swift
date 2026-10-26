import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelWarningSendEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let reason: String?
  public let chatRulesCited: [String]?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case reason
    case chatRulesCited
  }
}
