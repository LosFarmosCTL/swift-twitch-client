import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelUnbanEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
  }
}
