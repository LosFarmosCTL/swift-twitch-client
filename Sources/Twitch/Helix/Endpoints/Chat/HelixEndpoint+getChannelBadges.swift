import Foundation

extension HelixEndpoint {
  public static func getChannelBadges(
    of channel: String
  ) -> HelixEndpoint<[BadgeSet], BadgeSet, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/badges",
      queryItems: { _ in [("broadcaster_id", channel)] },
      makeResponse: { $0.data })
  }
}

public struct BadgeSet: Decodable, Sendable {
  public let setID: String
  public let badges: [Badge]

  enum CodingKeys: String, CodingKey {
    case setID = "setId"
    case badges = "versions"
  }
}

public struct Badge: Decodable, Sendable {
  public let id: String
  public let images: BadgeImages
  public let title: String
  public let description: String

  public let clickAction: String?
  public let clickUrl: String?

  enum CodingKeys: String, CodingKey {
    case id, title, description, clickAction, clickUrl
    case imageUrl1x = "imageUrl1X"
    case imageUrl2x = "imageUrl2X"
    case imageUrl4x = "imageUrl4X"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.images = BadgeImages(
      url1x: try container.decode(URL.self, forKey: .imageUrl1x),
      url2x: try container.decode(URL.self, forKey: .imageUrl2x),
      url4x: try container.decode(URL.self, forKey: .imageUrl4x))
    self.title = try container.decode(String.self, forKey: .title)
    self.description = try container.decode(String.self, forKey: .description)

    self.clickAction = try container.decodeIfPresent(String.self, forKey: .clickAction)
    self.clickUrl = try container.decodeIfPresent(String.self, forKey: .clickUrl)
  }

  public struct BadgeImages: Sendable {
    public let url1x: URL
    public let url2x: URL
    public let url4x: URL
  }
}
