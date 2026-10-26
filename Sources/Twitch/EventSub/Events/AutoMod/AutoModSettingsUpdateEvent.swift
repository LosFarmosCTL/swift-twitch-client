import MemberwiseInit

@MemberwiseInit(.public)
public struct AutoModSettingsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  public let overallLevel: Int?

  public let bullying: Int
  public let disability: Int
  public let raceEthnicityOrReligion: Int
  public let misogyny: Int
  public let sexualitySexOrGender: Int
  public let aggression: Int
  public let sexBasedTerms: Int
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
