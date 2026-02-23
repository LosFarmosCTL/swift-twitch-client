public struct ChannelWarningSendEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let reason: String?
  public let chatRulesCited: [String]?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case userID = "userId"
    case userLogin, userName

    case reason, chatRulesCited
  }
}
