import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannelBadges(
    of broadcasterID: String
  ) -> HelixEndpoint<[BadgeSet], BadgeSet, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/badges",
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      makeResponse: { $0.data })
  }
}

@MemberwiseInit(.public)
public struct BadgeSet: Decodable, Sendable {
  public let setID: String
  public let badges: [Badge]

  enum CodingKeys: String, CodingKey {
    case setID = "setId"
    case badges = "versions"
  }
}

@MemberwiseInit(.public)
public struct Badge: Decodable, Sendable {
  public let id: String
  public let images: BadgeImages
  public let title: String
  public let description: String

  public let clickAction: String?
  public let clickURL: String?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case description
    case clickAction
    case clickURL = "clickUrl"
    case imageURL1x = "imageUrl1X"
    case imageURL2x = "imageUrl2X"
    case imageURL4x = "imageUrl4X"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.images = BadgeImages(
      url1x: try container.decode(URL.self, forKey: .imageURL1x),
      url2x: try container.decode(URL.self, forKey: .imageURL2x),
      url4x: try container.decode(URL.self, forKey: .imageURL4x))
    self.title = try container.decode(String.self, forKey: .title)
    self.description = try container.decode(String.self, forKey: .description)

    self.clickAction = try container.decodeIfPresent(String.self, forKey: .clickAction)
    self.clickURL = try container.decodeIfPresent(String.self, forKey: .clickURL)
  }

  public struct BadgeImages: Sendable {
    public let url1x: URL
    public let url2x: URL
    public let url4x: URL
  }
}
