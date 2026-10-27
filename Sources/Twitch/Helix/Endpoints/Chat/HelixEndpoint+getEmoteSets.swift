import Foundation
import MemberwiseInit

/// A Twitch emote set identifier.
public typealias EmoteSetID = String

extension HelixEndpoint {
  /// Gets emotes from the requested emote sets.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-emote-sets
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - setIDs: The set IDs to include in the request.
  public static func getEmoteSets(
    _ setIDs: [EmoteSetID]
  ) -> HelixEndpoint<EmoteSetsResponse, SetEmote, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/emotes/set",
      authentication: .either,
      queryItems: { _ in
        setIDs.map { ("emote_set_id", $0) }
      },
      makeResponse: {
        let template = try $0.require(\.template)

        return EmoteSetsResponse(emotes: $0.data, template: template)
      }
    )
  }
}

/// The emotes in the requested sets and their image URL template.
@MemberwiseInit(.public)
public struct EmoteSetsResponse: Decodable, Sendable {
  /// The emote metadata.
  public let emotes: [SetEmote]

  /// The URL template used to construct image URLs.
  public let template: String
}

/// An emote belonging to a requested emote set.
@MemberwiseInit(.public)
public struct SetEmote: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The emote category, such as subscription, Bits tier, or follower.
  public let type: String
  /// The identifier of the set.
  public let setID: String
  /// The identifier of the owner.
  public let ownerID: String
  /// The supported image formats.
  public let format: [Emote.Format]
  /// The supported image scales.
  public let scale: [Emote.Scale]
  /// The supported image themes.
  public let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id, name
    case type = "emoteType"
    case setID = "emoteSetId"
    case ownerID = "ownerId"
    case format, scale, themeMode
  }

  /// Builds an emote image URL by substituting the ID, format, scale, and theme.
  ///
  /// Select a format supported by this emote. This method performs string substitution
  /// without checking image availability.
  ///
  /// - Returns: The constructed URL, or `nil` if the substituted string is not a valid
  ///   URL.
  ///
  /// - Parameters:
  ///   - templateURL: The image URL template returned by Twitch.
  ///   - format: The image format to substitute into the URL template. Defaults to
  ///     `.png`.
  ///   - scale: The image scale to substitute into the URL template. Defaults to
  ///     `.large`.
  ///   - themeMode: The theme to substitute into the URL template. Defaults to `.dark`.
  public func getURL(
    from templateURL: String, format: Emote.Format = .png, scale: Emote.Scale = .large,
    themeMode: Emote.ThemeMode = .dark
  ) -> URL? {
    return URL(
      string: templateURL.replacingOccurrences(of: "{{id}}", with: self.id)
        .replacingOccurrences(of: "{{scale}}", with: scale.rawValue).replacingOccurrences(
          of: "{{format}}", with: format.rawValue
        ).replacingOccurrences(of: "{{theme_mode}}", with: themeMode.rawValue))
  }
}
