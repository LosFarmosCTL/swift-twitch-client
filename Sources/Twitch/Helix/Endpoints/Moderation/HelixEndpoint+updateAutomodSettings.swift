import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<AutomodSettings> {
  private static func updateAutomodSettings(
    forChannel broadcasterID: String, moderatorID: String, body: Encodable
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID))

    return .init(
      method: "PUT", path: "moderation/automod/settings", queryItems: queryItems,
      body: body)
  }

  public static func updateAutomodSettings(
    forChannel broadcasterID: String, settings: AutomodConfiguration, moderatorID: String
  ) -> Self {
    self.updateAutomodSettings(
      forChannel: broadcasterID, moderatorID: moderatorID, body: settings)
  }

  public static func updateAutomodSettings(
    forChannel broadcasterID: String, overall level: Int, moderatorID: String
  ) -> Self {
    self.updateAutomodSettings(
      forChannel: broadcasterID, moderatorID: moderatorID, body: ["overall_level": level])
  }
}

public struct AutomodConfiguration: Encodable {
  let aggression: Int
  let bullying: Int
  let disability: Int
  let misogyny: Int
  let raceEthnicityOrReligion: Int
  let sexBasedTerms: Int
  let sexualitySexOrGender: Int
  let swearing: Int

  enum CodingKeys: String, CodingKey {
    case aggression, bullying, disability, misogyny, swearing

    case raceEthnicityOrReligion = "race_ethnicity_or_religion"
    case sexBasedTerms = "sex_based_terms"
    case sexualitySexOrGender = "sexuality_sex_or_gender"
  }
}
