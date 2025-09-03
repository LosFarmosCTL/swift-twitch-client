public struct ChannelUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let language: String

  public let categoryID: String
  public let categoryName: String

  public let contentClassificationLabels: [String]

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case categoryID = "categoryId"
    case categoryName

    case title, language, contentClassificationLabels
  }
}
