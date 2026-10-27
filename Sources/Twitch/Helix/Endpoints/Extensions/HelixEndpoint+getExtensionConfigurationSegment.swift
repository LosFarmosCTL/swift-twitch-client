import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets an extension’s configuration segment.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Use `TwitchCredentials.extensionJWT(token:clientID:)` with the signed JWT and the
  /// extension’s client ID. The client sends it as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-configuration-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - segments: The broadcaster, developer, or global configuration segments to
  ///     retrieve.
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
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
      authentication: .extensionJWT,
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("broadcaster_id", broadcasterID),
        ] + segmentItems
      },
      makeResponse: { $0.data })
  }
}

/// The broadcaster, developer, and global scopes of extension configuration.
public enum ExtensionConfigurationSegmentType: String, Codable, Sendable {
  /// Configuration scoped to a broadcaster.
  case broadcaster
  /// Configuration supplied by the extension developer.
  case developer
  /// Configuration shared across all broadcasters using the extension.
  case global
}

/// A stored extension configuration segment and its version.
@MemberwiseInit(.public)
public struct ExtensionConfigurationSegment: Decodable, Sendable {
  /// The configuration segment.
  public let segment: ExtensionConfigurationSegmentType
  /// The Twitch user ID of the broadcaster, when provided.
  public let broadcasterID: String?
  /// The stored configuration content, when provided.
  public let content: String?
  /// The version label assigned to this configuration segment.
  public let version: String
}
