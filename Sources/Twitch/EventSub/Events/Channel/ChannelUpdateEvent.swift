import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let title: String
  public let language: String

  public let categoryID: String
  public let categoryName: String

  public let contentClassificationLabels: [String]

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case categoryID = "categoryId"
    case categoryName
    case title
    case language
    case contentClassificationLabels
  }
}
