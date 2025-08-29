import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == AutomodSettings, HelixResponseType == AutomodSettings
{
  public static func getAutomodSettings(of channel: UserID) -> Self {
    return .init(
      method: "GET", path: "moderation/automod/settings",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      makeResponse: {
        guard let settings = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return settings
      })
  }
}

public struct AutomodSettings: Decodable, Sendable {
  public let broadcasterID: String
  public let moderatorID: String
  public let overallLevel: Int?

  public let disability: Int
  public let aggression: Int
  public let sexualitySexOrGender: Int
  public let misogyny: Int
  public let bullying: Int
  public let swearing: Int
  public let raceEthnicityOrReligion: Int
  public let sexBasedTerms: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case overallLevel

    case disability, aggression, sexualitySexOrGender, misogyny, bullying, swearing
    case raceEthnicityOrReligion, sexBasedTerms
  }
}
