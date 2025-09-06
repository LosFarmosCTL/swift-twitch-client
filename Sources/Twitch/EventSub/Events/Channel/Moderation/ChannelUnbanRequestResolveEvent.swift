public struct ChannelUnbanRequestResolveEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let moderatorID: String?
  public let moderatorLogin: String?
  public let moderatorName: String?

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let resolutionText: String?
  public let status: RequestStatus

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case moderatorID = "moderatorId"
    case moderatorLogin = "moderatorLogin"
    case moderatorName = "moderatorName"

    case userID = "userId"
    case userLogin, userName

    case resolutionText, status
  }

  public enum RequestStatus: String, Codable, Sendable {
    case approved
    case denied
    case canceled
  }
}
