import Foundation

extension HelixEndpoint {
  private static func updateAutomodSettings(
    of channel: String,
    body: Encodable & Sendable
  ) -> HelixEndpoint<
    AutomodSettings, AutomodSettings,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/automod/settings",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in body },
      makeResponse: {
        guard let settings = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return settings
      })
  }

  public static func updateAutomodSettings(
    of channel: String, settings: AutomodConfiguration
  ) -> HelixEndpoint<AutomodSettings, AutomodSettings, HelixEndpointResponseTypes.Normal>
  {
    self.updateAutomodSettings(of: channel, body: settings)
  }

  public static func updateAutomodSettings(of channel: String, overall level: Int)
    -> HelixEndpoint<
      AutomodSettings, AutomodSettings, HelixEndpointResponseTypes.Normal
    >
  {
    self.updateAutomodSettings(of: channel, body: ["overall_level": level])
  }
}

public struct AutomodConfiguration: Encodable, Sendable {
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
