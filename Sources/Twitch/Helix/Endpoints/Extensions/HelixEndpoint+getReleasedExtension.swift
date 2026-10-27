import Foundation

extension HelixEndpoint {
  /// Gets metadata for a released extension.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-released-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - version: The extension release version; `nil` requests the latest version.
  public static func getReleasedExtension(
    extensionID: String,
    version: String? = nil
  ) -> HelixEndpoint<Extension, Extension, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "extensions/released",
      authentication: .either,
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("extension_version", version),
        ]
      },
      makeResponse: { response in
        let extensionInfo = try response.requireFirst()

        return extensionInfo
      })
  }
}
