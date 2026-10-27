extension HelixEndpoint {
  /// Sets the configuration version required before a broadcaster can activate an extension.
  ///
  /// Requires an EBS-signed JWT with the `external` role and the extension owner’s user ID.
  /// Use `TwitchCredentials.extensionJWT(token:clientID:)` with the signed JWT and the
  /// extension’s client ID. The client sends it as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#set-extension-required-configuration
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster who installed the extension.
  ///   - extensionID: The extension’s ID.
  ///   - extensionVersion: The extension version to update.
  ///   - requiredConfiguration: The required configuration version string.
  public static func setExtensionRequiredConfiguration(
    for broadcasterID: String, extensionID: String, extensionVersion: String,
    requiredConfiguration: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "extensions/required_configuration",
      authentication: .extensionJWT,
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      body: { _ in
        [
          "extension_id": extensionID, "extension_version": extensionVersion,
          "required_configuration": requiredConfiguration,
        ]
      })
  }
}
