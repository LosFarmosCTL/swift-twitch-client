import Foundation

extension HelixEndpoint {
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
