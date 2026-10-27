import Foundation

extension HelixEndpoint {
  private static func updateAutoModSettings(
    of broadcasterID: String,
    moderatorID: String?,
    body: Encodable & Sendable
  ) -> HelixEndpoint<
    AutoModSettings, AutoModSettings,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "moderation/automod/settings",
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
      }, body: { _ in body },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }

  /// Updates a channel’s AutoMod configuration.
  ///
  /// With a user access token, requires `moderator:manage:automod_settings`. App tokens
  /// have additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-automod-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting moderator; required for app tokens, otherwise defaults to the token’s user.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - settings: The settings to apply.
  public static func updateAutoModSettings(
    of broadcasterID: String, settings: AutoModConfiguration, moderatorID: String? = nil
  ) -> HelixEndpoint<AutoModSettings, AutoModSettings, HelixEndpointResponseTypes.Normal>
  {
    self.updateAutoModSettings(
      of: broadcasterID, moderatorID: moderatorID, body: settings)
  }

  /// Updates a channel’s AutoMod configuration.
  ///
  /// With a user access token, requires `moderator:manage:automod_settings`. App tokens
  /// have additional grant requirements described in the reference. The moderator ID must
  /// match the token’s user, who must be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-automod-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting moderator; required for app tokens, otherwise defaults to the token’s user.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - overallLevel: The overall AutoMod filtering level.
  public static func updateAutoModSettings(
    of broadcasterID: String, overall overallLevel: Int, moderatorID: String? = nil
  )
    -> HelixEndpoint<
      AutoModSettings, AutoModSettings, HelixEndpointResponseTypes.Normal
    >
  {
    self.updateAutoModSettings(
      of: broadcasterID, moderatorID: moderatorID, body: ["overall_level": overallLevel])
  }
}

/// The individual AutoMod category levels to include in a settings update request.
public struct AutoModConfiguration: Encodable, Sendable {
  /// The AutoMod filtering level for aggression.
  public let aggression: Int
  /// The AutoMod filtering level for bullying.
  public let bullying: Int
  /// The AutoMod filtering level for disability.
  public let disability: Int
  /// The AutoMod filtering level for misogyny.
  public let misogyny: Int
  /// The AutoMod filtering level for race ethnicity or religion.
  public let raceEthnicityOrReligion: Int
  /// The AutoMod filtering level for sex based terms.
  public let sexBasedTerms: Int
  /// The AutoMod filtering level for sexuality sex or gender.
  public let sexualitySexOrGender: Int
  /// The AutoMod filtering level for swearing.
  public let swearing: Int

  enum CodingKeys: String, CodingKey {
    case aggression, bullying, disability, misogyny, swearing
    case raceEthnicityOrReligion, sexBasedTerms, sexualitySexOrGender
  }
}
