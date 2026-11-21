import Foundation

extension HelixEndpoint {
  /// Gets an extension’s configuration segment.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Use `TwitchCredentials.extensionJWT(token:clientID:)` with the signed JWT and the
  /// extension’s client ID. The client sends it as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/extensions/#get-extension-configuration-segment
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
  ) -> HelixEndpoint<[ExtensionConfigurationSegment]> {
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
      responseType: ExtensionConfigurationSegment.self, makeResponse: { $0.data })
  }
}

/// The broadcaster, developer, and global scopes of extension configuration, preserving
/// unfamiliar values in `rawValue`.
public struct ExtensionConfigurationSegmentType: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact segment type string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a segment type from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a segment type from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Encodes this segment type as its raw wire string.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// Configuration scoped to a broadcaster.
  public static let broadcaster = Self(rawValue: "broadcaster")
  /// Configuration supplied by the extension developer.
  public static let developer = Self(rawValue: "developer")
  /// Configuration shared across all broadcasters using the extension.
  public static let global = Self(rawValue: "global")
}

/// A stored extension configuration segment and its version.
public struct ExtensionConfigurationSegment: Decodable, Sendable {
  /// The configuration segment.
  public let segment: ExtensionConfigurationSegmentType
  /// The Twitch user ID of the broadcaster, when provided.
  public let broadcasterID: String?
  /// The stored configuration content, when provided.
  public let content: String?
  /// The version label assigned to this configuration segment.
  public let version: String

  /// Creates an `ExtensionConfigurationSegment` value.
  public init(
    segment: ExtensionConfigurationSegmentType,
    broadcasterID: String? = nil,
    content: String? = nil,
    version: String
  ) {
    self.segment = segment
    self.broadcasterID = broadcasterID
    self.content = content
    self.version = version
  }

  enum CodingKeys: String, CodingKey {
    case segment, content, version
    case broadcasterID = "broadcasterId"
  }
}
