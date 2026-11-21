import Foundation

extension HelixEndpoint {
  /// Updates the authenticated broadcaster’s channel information.
  ///
  /// With a user access token, requires `channel:manage:broadcast` or `user:edit:broadcast`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channels/#modify-channel-information
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - gameID: The identifier of the game, when provided.
  ///   - broadcasterLanguage: The broadcaster’s language code, when provided.
  ///   - title: The title shown to viewers, when provided.
  ///   - delay: The broadcast delay in seconds, when provided.
  ///   - tags: The stream tags, when provided.
  ///   - contentClassificationLabels: The content classification labels, when provided.
  ///   - isBrandedContent: Whether the stream is marked as branded content, when
  ///     provided.
  public static func updateChannel(
    gameID: String? = nil,
    broadcasterLanguage: String? = nil,
    title: String? = nil,
    delay: Int? = nil,
    tags: [String]? = nil,
    contentClassificationLabels: [ContentClassificationLabelID: Bool]? = nil,
    isBrandedContent: Bool? = nil
  ) -> HelixEndpoint<Void> {
    let contentClassificationLabels =
      contentClassificationLabels?.map { (id, isEnabled) in
        UpdateChannelRequestBody.ContentClassificationLabelUpdate(
          id: id.rawValue, isEnabled: isEnabled)
      }

    return .init(
      method: "PATCH", path: "channels",
      authentication: .user,
      queryItems: { credentials in
        [("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id"))]
      },
      body: { _ in
        UpdateChannelRequestBody(
          gameID: gameID,
          broadcasterLanguage: broadcasterLanguage,
          title: title,
          delay: delay,
          tags: tags,
          contentClassificationLabels: contentClassificationLabels,
          isBrandedContent: isBrandedContent)
      })
  }
}

/// Content labels that identify sensitive topics in a stream, preserving unfamiliar
/// values in `rawValue`.
public struct ContentClassificationLabelID: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact label identifier string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a content classification label ID from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a content classification label ID from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Encodes this content classification label ID as its raw wire string.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// A mature-rated game. Twitch applies this label automatically from the category;
  /// it cannot be toggled through the channel-update endpoint. Encoded as `"MatureGame"`.
  public static let matureGame = Self(rawValue: "MatureGame")
  /// Content depicting drugs or intoxication. Encoded as `"DrugsIntoxication"`.
  public static let drugsIntoxication = Self(rawValue: "DrugsIntoxication")
  /// Content containing sexual themes. Encoded as `"SexualThemes"`.
  public static let sexualThemes = Self(rawValue: "SexualThemes")
  /// Content containing graphic violence. Encoded as `"ViolentGraphic"`.
  public static let violentGraphic = Self(rawValue: "ViolentGraphic")
  /// Content containing gambling. Encoded as `"Gambling"`.
  public static let gambling = Self(rawValue: "Gambling")
  /// Content containing profanity or vulgarity. Encoded as `"ProfanityVulgarity"`.
  public static let profanityVulgarity = Self(rawValue: "ProfanityVulgarity")
  /// Content discussing debated social issues or politics. Encoded as
  /// `"DebatedSocialIssuesAndPolitics"`.
  public static let debatedSocialIssuesAndPolitics = Self(
    rawValue: "DebatedSocialIssuesAndPolitics")
}

internal struct UpdateChannelRequestBody: Encodable, Sendable {
  let gameID: String?
  let broadcasterLanguage: String?
  let title: String?
  let delay: Int?
  let tags: [String]?
  let contentClassificationLabels: [ContentClassificationLabelUpdate]?
  let isBrandedContent: Bool?

  struct ContentClassificationLabelUpdate: Encodable, Sendable {
    let id: String
    let isEnabled: Bool
  }

  enum CodingKeys: String, CodingKey {
    case gameID = "gameId"
    case broadcasterLanguage, title, delay, tags
    case contentClassificationLabels
    case isBrandedContent
  }

  enum LabelCodingKeys: String, CodingKey {
    case id, isEnabled
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(self.gameID, forKey: .gameID)
    try container.encodeIfPresent(self.broadcasterLanguage, forKey: .broadcasterLanguage)
    try container.encodeIfPresent(self.title, forKey: .title)
    try container.encodeIfPresent(self.delay, forKey: .delay)
    try container.encodeIfPresent(self.tags, forKey: .tags)
    try container.encodeIfPresent(self.isBrandedContent, forKey: .isBrandedContent)

    if let contentClassificationLabels {
      var labelsContainer = container.nestedUnkeyedContainer(
        forKey: .contentClassificationLabels)

      for label in contentClassificationLabels {
        var labelContainer = labelsContainer.nestedContainer(
          keyedBy: LabelCodingKeys.self)

        try labelContainer.encode(label.id, forKey: .id)
        try labelContainer.encode(label.isEnabled, forKey: .isEnabled)
      }
    }
  }
}
