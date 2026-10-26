import MemberwiseInit

/// An EventSub notification delivered when a channel’s AutoMod settings change.
@MemberwiseInit(.public)
public struct AutoModSettingsUpdateEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The login name of the moderator.
  public let moderatorLogin: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String

  /// The overall AutoMod filtering level, when provided.
  public let overallLevel: Int?

  /// The AutoMod filtering level for bullying.
  public let bullying: Int
  /// The AutoMod filtering level for disability.
  public let disability: Int
  /// The AutoMod filtering level for race ethnicity or religion.
  public let raceEthnicityOrReligion: Int
  /// The AutoMod filtering level for misogyny.
  public let misogyny: Int
  /// The AutoMod filtering level for sexuality sex or gender.
  public let sexualitySexOrGender: Int
  /// The AutoMod filtering level for aggression.
  public let aggression: Int
  /// The AutoMod filtering level for sex based terms.
  public let sexBasedTerms: Int
  /// The AutoMod filtering level for swearing.
  public let swearing: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorDisplayName = "moderatorUserName"
    case overallLevel
    case bullying
    case disability
    case raceEthnicityOrReligion
    case misogyny
    case sexualitySexOrGender
    case aggression
    case sexBasedTerms
    case swearing
  }
}
