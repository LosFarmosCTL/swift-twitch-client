import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelUnbanRequestResolveEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String?
  public let moderatorLogin: String?
  public let moderatorDisplayName: String?

  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let resolutionText: String?
  public let status: RequestStatus

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorId"
    case moderatorLogin
    case moderatorDisplayName = "moderatorName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case resolutionText
    case status
  }

  public enum RequestStatus: String, Codable, Sendable {
    case approved
    case denied
    case cancelled = "canceled"
  }
}
