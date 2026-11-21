import Foundation

extension HelixEndpoint {
  /// Gets a broadcaster’s channel-specific emotes.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/chat/#get-channel-emotes
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getChannelEmotes(
    of broadcasterID: String
  ) -> HelixEndpoint<ChannelEmotesResponse> {
    .init(
      method: "GET", path: "chat/emotes",
      authentication: .either,
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      responseType: ChannelEmote.self,
      makeResponse: {
        let template = try $0.require(\.template)

        return ChannelEmotesResponse(emotes: $0.data, template: template)
      })
  }
}

/// A channel’s custom emotes and the template used to construct their image URLs.
public struct ChannelEmotesResponse: Sendable {
  /// The emote metadata.
  public let emotes: [ChannelEmote]

  /// The URL template used to construct image URLs.
  public let template: String

  /// Creates a `ChannelEmotesResponse` value.
  public init(
    emotes: [ChannelEmote] = [],
    template: String
  ) {
    self.emotes = emotes
    self.template = template
  }
}

/// A channel emote’s identity, subscription requirements, and image variants.
public struct ChannelEmote: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The tier associated with the subscription, badge, or Cheermote, when provided.
  public let tier: String?
  /// The emote category, such as subscription, Bits tier, or follower.
  public let type: String
  /// The identifier of the set.
  public let setID: String
  /// The supported image formats.
  public let format: [Emote.Format]
  /// The supported image scales.
  public let scale: [Emote.Scale]
  /// The supported image themes.
  public let themeMode: [Emote.ThemeMode]

  /// Creates a `ChannelEmote` value.
  public init(
    id: String,
    name: String,
    tier: String? = nil,
    type: String,
    setID: String,
    format: [Emote.Format] = [],
    scale: [Emote.Scale] = [],
    themeMode: [Emote.ThemeMode] = []
  ) {
    self.id = id
    self.name = name
    self.tier = tier
    self.type = type
    self.setID = setID
    self.format = format
    self.scale = scale
    self.themeMode = themeMode
  }

  enum CodingKeys: String, CodingKey {
    case id, name, tier
    case type = "emoteType"
    case setID = "emoteSetId"
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

/// A namespace for image formats, scales, and themes used to build emote URLs.
public enum Emote: Sendable {
  /// The animated or static image variant to substitute into an emote URL template,
  /// preserving unfamiliar values in `rawValue`.
  public struct Format: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact format string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an emote format from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an emote format from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// An animated image format. Encoded as `"animated"`.
    public static let gif = Self(rawValue: "animated")
    /// A static image format. Encoded as `"static"`.
    public static let png = Self(rawValue: "static")
  }

  /// The image scale identifier to substitute into an emote URL template, preserving
  /// unfamiliar values in `rawValue`.
  public struct Scale: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact scale string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an emote scale from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an emote scale from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The 1× image scale. Encoded as `"1.0"`.
    public static let small = Self(rawValue: "1.0")
    /// The 2× image scale. Encoded as `"2.0"`.
    public static let medium = Self(rawValue: "2.0")
    /// The 3× image scale. Encoded as `"3.0"`.
    public static let large = Self(rawValue: "3.0")
  }

  /// The background theme for an emote image, preserving unfamiliar values in `rawValue`.
  public struct ThemeMode: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact theme mode string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an emote theme mode from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an emote theme mode from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Images for a light background.
    public static let light = Self(rawValue: "light")
    /// Images for a dark background.
    public static let dark = Self(rawValue: "dark")
  }
}
