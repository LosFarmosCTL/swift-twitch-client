import Foundation

extension HelixEndpoint {
  private static func updateAutoModSettings(
    of broadcasterID: String,
    body: Encodable & Sendable
  ) -> HelixEndpoint<
    AutoModSettings, AutoModSettings,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/automod/settings",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      }, body: { _ in body },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }

  public static func updateAutoModSettings(
    of broadcasterID: String, settings: AutoModConfiguration
  ) -> HelixEndpoint<AutoModSettings, AutoModSettings, HelixEndpointResponseTypes.Normal>
  {
    self.updateAutoModSettings(of: broadcasterID, body: settings)
  }

  public static func updateAutoModSettings(
    of broadcasterID: String, overall overallLevel: Int
  )
    -> HelixEndpoint<
      AutoModSettings, AutoModSettings, HelixEndpointResponseTypes.Normal
    >
  {
    self.updateAutoModSettings(
      of: broadcasterID, body: ["overall_level": overallLevel])
  }
}

public struct AutoModConfiguration: Encodable, Sendable {
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
