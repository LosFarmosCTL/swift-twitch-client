public struct ChannelCheerEvent: Event {
  public let isAnonymous: Bool

  // null if anonymous
  public let userID: String?
  public let userLogin: String?
  public let userName: String?

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let message: String
  public let bits: Int

  enum CodingKeys: String, CodingKey {
    case isAnonymous

    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case message, bits
  }
}
