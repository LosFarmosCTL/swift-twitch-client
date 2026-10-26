import Foundation

extension HelixEndpoint {
  /// Stores an extension configuration segment.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#set-extension-configuration-segment
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - segment: The configuration segment.
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
  ///   - content: The content to store or send.
  ///   - version: A version label for the configuration content; this is separate from
  ///     the extension’s release version.
  public static func setExtensionConfigurationSegment(
    extensionID: String,
    segment: ExtensionConfigurationSegmentType,
    broadcasterID: String? = nil,
    content: String? = nil,
    version: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "extensions/configurations",
      body: { _ in
        SetExtensionConfigurationSegmentRequestBody(
          extensionID: extensionID,
          segment: segment,
          broadcasterID: broadcasterID,
          content: content,
          version: version)
      })
  }
}

// swiftlint:disable:next type_name
private struct SetExtensionConfigurationSegmentRequestBody: Encodable, Sendable {
  let extensionID: String
  let segment: ExtensionConfigurationSegmentType
  let broadcasterID: String?
  let content: String?
  let version: String?
}
