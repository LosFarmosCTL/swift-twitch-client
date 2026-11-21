import Foundation

extension HelixEndpoint {
  /// Gets a channel’s AutoMod configuration.
  ///
  /// With a user access token, requires `moderator:read:automod_settings` or
  /// `moderator:manage:automod_settings`. App tokens have additional grant requirements
  /// described in the reference. The moderator ID must match the token’s user, who must
  /// be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#get-automod-settings
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getAutoModSettings(
    of broadcasterID: String,
    moderatorID: String? = nil
  )
    -> HelixEndpoint<AutoModSettings>
  {
    .init(
      method: "GET", path: "moderation/automod/settings",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
        ]
      },
      responseType: AutoModSettings.self,
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

/// A channel’s current AutoMod configuration and moderator identity.
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

  /// Creates an `AutoModSettings` value.
  public init(
    broadcasterID: String,
    moderatorID: String,
    overallLevel: Int? = nil,
    disability: Int,
    aggression: Int,
    sexualitySexOrGender: Int,
    misogyny: Int,
    bullying: Int,
    swearing: Int,
    raceEthnicityOrReligion: Int,
    sexBasedTerms: Int
  ) {
    self.broadcasterID = broadcasterID
    self.moderatorID = moderatorID
    self.overallLevel = overallLevel
    self.disability = disability
    self.aggression = aggression
    self.sexualitySexOrGender = sexualitySexOrGender
    self.misogyny = misogyny
    self.bullying = bullying
    self.swearing = swearing
    self.raceEthnicityOrReligion = raceEthnicityOrReligion
    self.sexBasedTerms = sexBasedTerms
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case overallLevel

    case disability, aggression, sexualitySexOrGender, misogyny, bullying, swearing
    case raceEthnicityOrReligion, sexBasedTerms
  }
}
