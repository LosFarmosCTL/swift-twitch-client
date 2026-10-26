import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelCheerEvent: Event {
  public let isAnonymous: Bool

  // null if anonymous
  public let userID: String?
  public let userLogin: String?
  public let userDisplayName: String?

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let message: String
  public let bits: Int

  enum CodingKeys: String, CodingKey {
    case isAnonymous
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case message
    case bits
  }
}
