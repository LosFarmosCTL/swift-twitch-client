public struct AutomodTermsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String
  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

  public let action: Action
  public let fromAutomod: Bool
  public let terms: [String]

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"
    case action, fromAutomod, terms
  }

  public enum Action: String, Decodable, Sendable {
    case addPermitted = "add_permitted"
    case addBlocked = "add_blocked"
    case removePermitted = "remove_permitted"
    case removeBlocked = "remove_blocked"
  }
}
