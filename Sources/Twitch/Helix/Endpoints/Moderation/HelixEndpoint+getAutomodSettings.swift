import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<AutomodSettings> {
  public static func getAutomodSettings(
    for broadcasterID: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID))

    return .init(
      method: "GET", path: "moderation/automod/settings", queryItems: queryItems)
  }
}

public struct AutomodSettings: Decodable {
  let broadcasterID: String
  let moderatorID: String
  let overallLevel: Int?

  let disability: Int
  let aggression: Int
  let sexualitySexOrGender: Int
  let misogyny: Int
  let bullying: Int
  let swearing: Int
  let raceEthnicityOrReligion: Int
  let sexBasedTerms: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case moderatorID = "moderator_id"
    case overallLevel = "overall_level"

    case disability
    case aggression
    case sexualitySexOrGender = "sexuality_sex_or_gender"
    case misogyny
    case bullying
    case swearing
    case raceEthnicityOrReligion = "race_ethnicity_or_religion"
    case sexBasedTerms = "sex_based_terms"
  }
}
