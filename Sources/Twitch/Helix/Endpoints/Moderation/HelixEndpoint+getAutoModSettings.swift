import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s AutoMod configuration.
  ///
  /// With a user access token, requires `moderator:read:automod_settings` or
  /// `moderator:manage:automod_settings`. App tokens have additional grant requirements
  /// described in the reference. The moderator ID must match the token’s user, who must
  /// be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-automod-settings
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getAutoModSettings(of broadcasterID: String)
    -> HelixEndpoint<AutoModSettings, AutoModSettings, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "moderation/automod/settings",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

/// A channel’s current AutoMod configuration and moderator identity.
@MemberwiseInit(.public)
public struct AutoModSettings: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The overall AutoMod filtering level, when provided.
  public let overallLevel: Int?

  /// The AutoMod filtering level for disability.
  public let disability: Int
  /// The AutoMod filtering level for aggression.
  public let aggression: Int
  /// The AutoMod filtering level for sexuality sex or gender.
  public let sexualitySexOrGender: Int
  /// The AutoMod filtering level for misogyny.
  public let misogyny: Int
  /// The AutoMod filtering level for bullying.
  public let bullying: Int
  /// The AutoMod filtering level for swearing.
  public let swearing: Int
  /// The AutoMod filtering level for race ethnicity or religion.
  public let raceEthnicityOrReligion: Int
  /// The AutoMod filtering level for sex based terms.
  public let sexBasedTerms: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case overallLevel

    case disability, aggression, sexualitySexOrGender, misogyny, bullying, swearing
    case raceEthnicityOrReligion, sexBasedTerms
  }
}
