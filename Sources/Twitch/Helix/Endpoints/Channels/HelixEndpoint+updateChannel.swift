import Foundation

extension HelixEndpoint {
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

public enum ContentClassificationLabelID: String, Codable, Sendable {
  case drugsIntoxication = "DrugsIntoxication"
  case sexualThemes = "SexualThemes"
  case violentGraphic = "ViolentGraphic"
  case gambling = "Gambling"
  case profanityVulgarity = "ProfanityVulgarity"
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
