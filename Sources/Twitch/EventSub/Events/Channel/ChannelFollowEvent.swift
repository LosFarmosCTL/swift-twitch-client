import Foundation

public struct ChannelFollowEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case followedAt
  }
}
