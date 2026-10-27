import Foundation

extension HelixEndpoint {
  /// Updates the authenticated broadcaster’s channel information.
  ///
  /// With a user access token, requires `channel:manage:broadcast`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#modify-channel-information
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
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    let contentClassificationLabels =
      contentClassificationLabels?.map { (id, isEnabled) in
        UpdateChannelRequestBody.ContentClassificationLabelUpdate(
          id: id.rawValue, isEnabled: isEnabled)
      }

    return .init(
      method: "PATCH", path: "channels",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
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

/// Content labels that identify sensitive topics in a stream.
public enum ContentClassificationLabelID: String, Codable, Sendable {
  /// A mature-rated game. Twitch applies this label automatically from the category;
  /// it cannot be toggled through the channel-update endpoint. Encoded as `"MatureGame"`.
  case matureGame = "MatureGame"
  /// Content depicting drugs or intoxication. Encoded as `"DrugsIntoxication"`.
  case drugsIntoxication = "DrugsIntoxication"
  /// Content containing sexual themes. Encoded as `"SexualThemes"`.
  case sexualThemes = "SexualThemes"
  /// Content containing graphic violence. Encoded as `"ViolentGraphic"`.
  case violentGraphic = "ViolentGraphic"
  /// Content containing gambling. Encoded as `"Gambling"`.
  case gambling = "Gambling"
  /// Content containing profanity or vulgarity. Encoded as `"ProfanityVulgarity"`.
  case profanityVulgarity = "ProfanityVulgarity"
  /// Content discussing debated social issues or politics. Encoded as
  /// `"DebatedSocialIssuesAndPolitics"`.
  case debatedSocialIssuesAndPolitics = "DebatedSocialIssuesAndPolitics"
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
