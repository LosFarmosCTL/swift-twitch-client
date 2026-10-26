import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets Twitch’s global emotes.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-global-emotes
  /// ) for request limits and account requirements.
  public static func getGlobalEmotes()
    -> HelixEndpoint<GlobalEmotesResponse, GlobalEmote, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "chat/emotes/global",
      makeResponse: {
        let template = try $0.require(\.template)

        return GlobalEmotesResponse(emotes: $0.data, template: template)

      })
  }
}

/// Twitch’s global emotes and the template used to construct their image URLs.
public struct GlobalEmotesResponse: Sendable {
  /// The emote metadata.
  public let emotes: [GlobalEmote]

  /// The URL template used to construct image URLs.
  public let template: String
}

/// A global emote’s identity and available image variants.
@MemberwiseInit(.public)
public struct GlobalEmote: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The supported image formats.
  public let format: [Emote.Format]
  /// The supported image scales.
  public let scale: [Emote.Scale]
  /// The supported image themes.
  public let themeMode: [Emote.ThemeMode]

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
