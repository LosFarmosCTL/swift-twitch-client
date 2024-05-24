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
  public let aggression: Int
  public let bullying: Int
  public let disability: Int
  public let misogyny: Int
  public let raceEthnicityOrReligion: Int
  public let sexBasedTerms: Int
  public let sexualitySexOrGender: Int
  public let swearing: Int

  enum CodingKeys: String, CodingKey {
    case aggression, bullying, disability, misogyny, swearing
    case raceEthnicityOrReligion, sexBasedTerms, sexualitySexOrGender
  }
}
