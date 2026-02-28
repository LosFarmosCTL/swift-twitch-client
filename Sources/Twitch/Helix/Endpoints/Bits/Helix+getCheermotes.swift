import Foundation

extension HelixEndpoint {
  public static func getCheermotes(
    broadcasterID: String? = nil
  ) -> HelixEndpoint<[Cheermote], Cheermote, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "bits/cheermotes",
      queryItems: { _ in
        [("broadcaster_id", broadcasterID)]
      },
      makeResponse: { $0.data })
  }
}

public struct Cheermote: Decodable, Sendable {
  public let prefix: String
  public let tiers: [CheermoteTier]
  public let type: String
  public let order: Int
  public let lastUpdated: Date
  public let isCharitable: Bool
}

public struct CheermoteTier: Decodable, Sendable {
  public let minBits: Int
  public let id: String
  public let color: String
  public let images: CheermoteImages
  public let canCheer: Bool
  public let showInBitsCard: Bool
}

public struct CheermoteImages: Decodable, Sendable {
  public let dark: CheermoteImageSet
  public let light: CheermoteImageSet
}

public struct CheermoteImageSet: Decodable, Sendable {
  public let animated: CheermoteImageScaleSet
  public let staticImages: CheermoteImageScaleSet

  enum CodingKeys: String, CodingKey {
    case animated
    case staticImages = "static"
  }
}

// swiftlint:disable identifier_name
public struct CheermoteImageScaleSet: Decodable, Sendable {
  public let url1x: String
  public let url1_5x: String
  public let url2x: String
  public let url3x: String
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
