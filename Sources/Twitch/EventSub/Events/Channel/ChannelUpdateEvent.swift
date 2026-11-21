/// An EventSub notification delivered when a broadcaster updates channel metadata.
public struct ChannelUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The title shown to viewers.
  public let title: String
  /// The language code reported by Twitch.
  public let language: String

  /// The identifier of the category.
  public let categoryID: String
  /// The name of the category.
  public let categoryName: String

  /// The content classification labels.
  public let contentClassificationLabels: [String]

  /// Creates a `ChannelUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    language: String,
    categoryID: String,
    categoryName: String,
    contentClassificationLabels: [String] = []
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.language = language
    self.categoryID = categoryID
    self.categoryName = categoryName
    self.contentClassificationLabels = contentClassificationLabels
  }

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
