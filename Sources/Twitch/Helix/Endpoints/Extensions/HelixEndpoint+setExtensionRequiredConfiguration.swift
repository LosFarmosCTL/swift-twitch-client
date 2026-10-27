extension HelixEndpoint {
  /// Sets the configuration version required before a broadcaster can activate an extension.
  ///
  /// Requires an EBS-signed JWT with the `external` role and the extension owner’s user ID.
  /// Supply the signed JWT as `TwitchCredentials.accessToken` and the extension’s client ID
  /// as `clientID`. The client sends the JWT as a Bearer token; it does not sign JWTs.
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
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      body: { _ in
        [
          "extension_id": extensionID, "extension_version": extensionVersion,
          "required_configuration": requiredConfiguration,
        ]
      })
  }
}
