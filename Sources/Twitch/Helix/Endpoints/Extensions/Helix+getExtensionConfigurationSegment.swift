import Foundation

extension HelixEndpoint {
  public static func getExtensionConfigurationSegment(
    extensionID: String,
    segments: [ExtensionConfigurationSegmentType],
    broadcasterID: String? = nil
  ) -> HelixEndpoint<
    [ExtensionConfigurationSegment], ExtensionConfigurationSegment,
    HelixEndpointResponseTypes.Normal
  > {
    let segmentItems = segments.map { ("segment", $0.rawValue) }

    return .init(
      method: "GET", path: "extensions/configurations",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("broadcaster_id", broadcasterID),
        ] + segmentItems
      },
      makeResponse: { $0.data })
  }
}

public enum ExtensionConfigurationSegmentType: String, Codable, Sendable {
  case broadcaster
  case developer
  case global
}

public struct ExtensionConfigurationSegment: Decodable, Sendable {
  public let segment: ExtensionConfigurationSegmentType
  public let broadcasterID: String?
  public let content: String?
  public let version: String
}
