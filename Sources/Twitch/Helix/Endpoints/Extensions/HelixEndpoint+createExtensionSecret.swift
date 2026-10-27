import Foundation

extension HelixEndpoint {
  /// Rotates an extension’s signing secret.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Supply the signed JWT as `TwitchCredentials.accessToken` and the extension’s client ID
  /// as `clientID`. The client sends the JWT as a Bearer token; it does not sign JWTs.
  ///
  /// Rotation creates a new secret and schedules retirement of existing secrets.
  /// Coordinate the cutover using the returned activation and expiration timestamps.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-extension-secret
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - delay: Seconds before the new secret becomes active. Twitch defaults to 300
  ///     seconds when `nil`; the minimum is 300.
  public static func createExtensionSecret(
    extensionID: String,
    delay: Int? = nil
  ) -> HelixEndpoint<
    ExtensionSecretsResponse, ExtensionSecretsResponse,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "extensions/jwt/secrets",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("delay", delay.map(String.init)),
        ]
      },
      makeResponse: { response in
        let secrets = try response.requireFirst()

        return secrets
      })
  }
}
