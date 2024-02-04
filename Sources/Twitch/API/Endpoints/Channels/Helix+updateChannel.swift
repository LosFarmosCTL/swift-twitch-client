import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func updateChannel(
    gameId: String? = nil, broadcasterLanguage: String? = nil, title: String? = nil,
    delay: Int? = nil, tag: [String]? = nil,
    contentClassificationLabels: [Label: Bool]? = nil, isBrandedContent: Bool? = nil
  ) async throws {
    let contentClassificationLabels = contentClassificationLabels?.map {
      (id, isEnabled) in
      UpdateChannelRequestBody.Label(id: id.rawValue, isEnabled: isEnabled)
    }

    let body = UpdateChannelRequestBody(
      gameId: gameId, broadcasterLanguage: broadcasterLanguage, title: title,
      delay: delay, tags: tag, contentClassificationLabels: contentClassificationLabels,
      isBrandedContent: isBrandedContent)

    let queryItems = self.makeQueryItems(("broadcaster_id", self.authenticatedUserId))

    (_, _) =
      try await self.request(.patch("channels"), with: queryItems, jsonBody: body)
      as (String, HelixData<Int>?)
  }
}

public enum Label: String, Encodable {
  case drugsIntoxication = "DrugsIntoxication"
  case sexualThemes = "SexualThemes"
  case violentGraphic = "ViolentGraphic"
  case gambling = "Gambling"
  case profanityVulgarity = "ProfanityVulgarity"
}

internal struct UpdateChannelRequestBody: Encodable {
  let gameId: String?
  let broadcasterLanguage: String?
  let title: String?
  let delay: Int?
  let tags: [String]?
  let contentClassificationLabels: [Label]?
  let isBrandedContent: Bool?

  struct Label: Encodable {
    let id: String
    let isEnabled: Bool
  }

  enum CodingKeys: String, CodingKey {
    case gameId = "game_id"
    case broadcasterLanguage = "broadcaster_language"
    case title
    case delay
    case tags
    case contentClassificationLabels = "content_classification_labels"
    case isBrandedContent = "is_branded_content"
  }

  enum LabelCodingKeys: String, CodingKey {
    case id
    case isEnabled = "is_enabled"
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(self.gameId, forKey: .gameId)
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
