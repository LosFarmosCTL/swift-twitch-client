/// An EventSub notification delivered when a channel’s AutoMod settings change.
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

  /// Creates an `AutoModSettingsUpdateEvent` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    moderatorID: String,
    moderatorLogin: String,
    moderatorDisplayName: String,
    overallLevel: Int? = nil,
    bullying: Int,
    disability: Int,
    raceEthnicityOrReligion: Int,
    misogyny: Int,
    sexualitySexOrGender: Int,
    aggression: Int,
    sexBasedTerms: Int,
    swearing: Int
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.overallLevel = overallLevel
    self.bullying = bullying
    self.disability = disability
    self.raceEthnicityOrReligion = raceEthnicityOrReligion
    self.misogyny = misogyny
    self.sexualitySexOrGender = sexualitySexOrGender
    self.aggression = aggression
    self.sexBasedTerms = sexBasedTerms
    self.swearing = swearing
  }

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
