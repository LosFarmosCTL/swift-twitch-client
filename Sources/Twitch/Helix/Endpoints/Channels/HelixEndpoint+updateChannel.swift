import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func updateChannel(
    gameID: String? = nil,
    broadcasterLanguage: String? = nil,
    title: String? = nil,
    delay: Int? = nil,
    tag: [String]? = nil,
    contentClassificationLabels: [Label: Bool]? = nil,
    isBrandedContent: Bool? = nil
  ) -> Self {
    let contentClassificationLabels =
      contentClassificationLabels?.map { (id, isEnabled) in
        UpdateChannelRequestBody.Label(id: id.rawValue, isEnabled: isEnabled)
      }

    return .init(
      method: "PATCH", path: "channels",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      body: { _ in
        UpdateChannelRequestBody(
          gameID: gameID,
          broadcasterLanguage: broadcasterLanguage,
          title: title,
          delay: delay,
          tags: tag,
          contentClassificationLabels: contentClassificationLabels,
          isBrandedContent: isBrandedContent)
      })
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
  let gameID: String?
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
