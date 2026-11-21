import Foundation

extension HelixEndpoint {
  /// Gets the Cheermotes available globally or in a specified channel.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/bits/#get-cheermotes
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
  public static func getCheermotes(
    broadcasterID: String? = nil
  ) -> HelixEndpoint<[Cheermote]> {
    .init(
      method: "GET", path: "bits/cheermotes",
      authentication: .either,
      queryItems: { _ in
        [("broadcaster_id", broadcasterID)]
      },
      responseType: Cheermote.self, makeResponse: { $0.data })
  }
}

/// A Bits Cheermote prefix and its available contribution tiers.
public struct Cheermote: Decodable, Sendable {
  /// The prefix used to identify the Cheermote in chat.
  public let prefix: String
  /// The Cheermote tiers.
  public let tiers: [CheermoteTier]
  /// The Cheermote category, such as global or channel-specific.
  public let type: String
  /// The display order.
  public let order: Int
  /// The time the resource was last updated.
  public let lastUpdated: Date
  /// Whether the contribution supports charity.
  public let isCharitable: Bool

  /// Creates a `Cheermote` value.
  public init(
    prefix: String,
    tiers: [CheermoteTier] = [],
    type: String,
    order: Int,
    lastUpdated: Date,
    isCharitable: Bool
  ) {
    self.prefix = prefix
    self.tiers = tiers
    self.type = type
    self.order = order
    self.lastUpdated = lastUpdated
    self.isCharitable = isCharitable
  }
}

/// A Cheermote contribution tier, including its threshold, color, and images.
public struct CheermoteTier: Decodable, Sendable {
  /// The minimum number of Bits required for this tier.
  public let minBits: Int
  /// The identifier assigned by Twitch.
  public let id: String
  /// The color reported by Twitch.
  public let color: String
  /// The image URLs for the available sizes.
  public let images: CheermoteImages
  /// Whether viewers can use this Cheermote.
  public let canCheer: Bool
  /// Whether the product is shown in the Bits product card.
  public let showInBitsCard: Bool

  /// Creates a `CheermoteTier` value.
  public init(
    minBits: Int,
    id: String,
    color: String,
    images: CheermoteImages,
    canCheer: Bool,
    showInBitsCard: Bool
  ) {
    self.minBits = minBits
    self.id = id
    self.color = color
    self.images = images
    self.canCheer = canCheer
    self.showInBitsCard = showInBitsCard
  }
}

/// The dark and light image variants for a Cheermote tier.
public struct CheermoteImages: Decodable, Sendable {
  /// The images for the dark theme.
  public let dark: CheermoteImageSet
  /// The images for the light theme.
  public let light: CheermoteImageSet

  /// Creates a `CheermoteImages` value.
  public init(
    dark: CheermoteImageSet,
    light: CheermoteImageSet
  ) {
    self.dark = dark
    self.light = light
  }
}

/// The static and animated images for a Cheermote theme.
public struct CheermoteImageSet: Decodable, Sendable {
  /// The animated image variants.
  public let animated: CheermoteImageScaleSet
  /// The static image variants.
  public let staticImages: CheermoteImageScaleSet

  /// Creates a `CheermoteImageSet` value.
  public init(
    animated: CheermoteImageScaleSet,
    staticImages: CheermoteImageScaleSet
  ) {
    self.animated = animated
    self.staticImages = staticImages
  }

  enum CodingKeys: String, CodingKey {
    case animated
    case staticImages = "static"
  }
}

// swiftlint:disable identifier_name
/// Cheermote image URLs indexed by display scale.
public struct CheermoteImageScaleSet: Decodable, Sendable {
  /// The image URL at 1× scale.
  public let url1x: String
  // swift-format-ignore: AlwaysUseLowerCamelCase
  /// The image URL at 1.5× scale.
  public let url1_5x: String
  /// The image URL at 2× scale.
  public let url2x: String
  /// The image URL at 3× scale.
  public let url3x: String
  /// The image URL at 4× scale.
  public let url4x: String

  /// Creates a `CheermoteImageScaleSet` value.
  public init(
    url1x: String,
    url1_5x: String,
    url2x: String,
    url3x: String,
    url4x: String
  ) {
    self.url1x = url1x
    self.url1_5x = url1_5x
    self.url2x = url2x
    self.url3x = url3x
    self.url4x = url4x
  }

  enum CodingKeys: String, CodingKey {
    case url1x = "1"
    // swift-format-ignore: AlwaysUseLowerCamelCase
    case url1_5x = "1.5"
    case url2x = "2"
    case url3x = "3"
    case url4x = "4"
  }
}
// swiftlint:enable identifier_name
