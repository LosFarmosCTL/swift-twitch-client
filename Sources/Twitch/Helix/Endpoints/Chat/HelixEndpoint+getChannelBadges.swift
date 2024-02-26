import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BadgeSet> {
  public static func getChannelBadges(of channel: UserID) -> Self {
    let queryItems = self.makeQueryItems(("broadcaster_id", channel))

    return .init(method: "GET", path: "chat/badges", queryItems: queryItems)
  }
}

public struct BadgeSet: Decodable {
  let setID: String
  let badges: [Badge]

  enum CodingKeys: String, CodingKey {
    case setID = "set_id"
    case badges = "versions"
  }
}

public struct Badge: Decodable {
  let id: String
  let images: BadgeImages
  let title: String
  let description: String

  let clickAction: String?
  let clickUrl: String?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case imageUrl1x = "image_url_1x"
    case imageUrl2x = "image_url_2x"
    case imageUrl4x = "image_url_4x"
    case title = "title"
    case description = "description"

    case clickAction = "click_action"
    case clickUrl = "click_url"
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

  struct BadgeImages {
    let url1x: URL
    let url2x: URL
    let url4x: URL
  }
}
