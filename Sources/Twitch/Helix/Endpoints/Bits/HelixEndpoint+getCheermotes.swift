import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the Cheermotes available globally or in a specified channel.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-cheermotes
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
  public static func getCheermotes(
    broadcasterID: String? = nil
  ) -> HelixEndpoint<[Cheermote], Cheermote, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "bits/cheermotes",
      authentication: .either,
      queryItems: { _ in
        [("broadcaster_id", broadcasterID)]
      },
      makeResponse: { $0.data })
  }
}

/// A Bits Cheermote prefix and its available contribution tiers.
@MemberwiseInit(.public)
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
}

/// A Cheermote contribution tier, including its threshold, color, and images.
@MemberwiseInit(.public)
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
}

/// The dark and light image variants for a Cheermote tier.
@MemberwiseInit(.public)
public struct CheermoteImages: Decodable, Sendable {
  /// The images for the dark theme.
  public let dark: CheermoteImageSet
  /// The images for the light theme.
  public let light: CheermoteImageSet
}

/// The static and animated images for a Cheermote theme.
@MemberwiseInit(.public)
public struct CheermoteImageSet: Decodable, Sendable {
  /// The animated image variants.
  public let animated: CheermoteImageScaleSet
  /// The static image variants.
  public let staticImages: CheermoteImageScaleSet

  enum CodingKeys: String, CodingKey {
    case animated
    case staticImages = "static"
  }
}

// swiftlint:disable identifier_name
/// Cheermote image URLs indexed by display scale.
@MemberwiseInit(.public)
public struct CheermoteImageScaleSet: Decodable, Sendable {
  /// The image URL at 1× scale.
  public let url1x: String
  /// The image URL at 1.5× scale.
  public let url1_5x: String
  /// The image URL at 2× scale.
  public let url2x: String
  /// The image URL at 3× scale.
  public let url3x: String
  /// The image URL at 4× scale.
  public let url4x: String

  enum CodingKeys: String, CodingKey {
    case url1x = "1"
    case url1_5x = "1.5"
    case url2x = "2"
    case url3x = "3"
    case url4x = "4"
  }
}
// swiftlint:enable identifier_name
