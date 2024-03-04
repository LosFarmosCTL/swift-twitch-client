import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == AutomodSettings, HelixResponseType == AutomodSettings
{
  private static func updateAutomodSettings(
    of channel: UserID, body: Encodable
  ) -> Self {
    return .init(
      method: "PUT", path: "moderation/automod/settings",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in body },
      makeResponse: {
        guard let settings = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return settings
      })
  }

  public static func updateAutomodSettings(
    of channel: UserID, settings: AutomodConfiguration
  ) -> Self {
    self.updateAutomodSettings(of: channel, body: settings)
  }

  public static func updateAutomodSettings(of channel: UserID, overall level: Int) -> Self
  {
    self.updateAutomodSettings(of: channel, body: ["overall_level": level])
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
