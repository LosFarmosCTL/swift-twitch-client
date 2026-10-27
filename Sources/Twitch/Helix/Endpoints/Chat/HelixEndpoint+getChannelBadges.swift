import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a broadcaster’s channel-specific chat badge sets.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-chat-badges
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getChannelBadges(
    of broadcasterID: String
  ) -> HelixEndpoint<[BadgeSet], BadgeSet, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/badges",
      authentication: .either,
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      makeResponse: { $0.data })
  }
}

/// A chat badge set and its available badge versions.
@MemberwiseInit(.public)
public struct BadgeSet: Decodable, Sendable {
  /// The identifier of the set.
  public let setID: String
  /// The chat badges.
  public let badges: [Badge]

  enum CodingKeys: String, CodingKey {
    case setID = "setId"
    case badges = "versions"
  }
}

/// A chat badge version with image URLs, title, and click behavior.
@MemberwiseInit(.public)
public struct Badge: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The image URLs for the available sizes.
  public let images: BadgeImages
  /// The title shown to viewers.
  public let title: String
  /// The descriptive text supplied by Twitch.
  public let description: String

  /// The action performed when a viewer clicks the badge, when provided.
  public let clickAction: String?
  /// The URL for click, when provided.
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

  /// Decodes a badge, collecting the image URLs into `images`.
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

  /// The image URLs for a chat badge at each supported display scale.
  public struct BadgeImages: Sendable {
    /// The image URL at 1× scale.
    public let url1x: URL
    /// The image URL at 2× scale.
    public let url2x: URL
    /// The image URL at 4× scale.
    public let url4x: URL
  }
}
