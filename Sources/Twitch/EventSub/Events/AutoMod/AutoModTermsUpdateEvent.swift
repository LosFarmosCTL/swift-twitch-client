import MemberwiseInit

@MemberwiseInit(.public)
public struct AutoModTermsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String
  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let action: Action
  public let fromAutoMod: Bool
  public let terms: [String]

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case action
    case fromAutoMod = "fromAutomod"
    case terms
  }

  public enum Action: String, Decodable, Sendable {
    case addPermitted = "add_permitted"
    case addBlocked = "add_blocked"
    case removePermitted = "remove_permitted"
    case removeBlocked = "remove_blocked"
  }
}
