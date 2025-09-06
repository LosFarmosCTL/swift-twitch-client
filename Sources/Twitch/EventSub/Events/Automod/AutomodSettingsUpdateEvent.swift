public struct AutomodSettingsUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorName: String

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
    case broadcasterName = "broadcasterUserName"

    case moderatorID = "moderatorUserId"
    case moderatorLogin = "moderatorUserLogin"
    case moderatorName = "moderatorUserName"

    case overallLevel, bullying, disability, raceEthnicityOrReligion, misogyny,
      sexualitySexOrGender, aggression, sexBasedTerms, swearing
  }
}
