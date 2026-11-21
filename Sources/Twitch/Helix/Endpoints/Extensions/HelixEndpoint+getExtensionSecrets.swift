import Foundation

extension HelixEndpoint {
  /// Gets an extension’s signing secrets and their validity periods.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Use `TwitchCredentials.extensionJWT(token:clientID:)` with the signed JWT and the
  /// extension’s client ID. The client sends it as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/extensions/#get-extension-secrets
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  public static func getExtensionSecrets(
    extensionID: String
  ) -> HelixEndpoint<ExtensionSecretsResponse> {
    .init(
      method: "GET", path: "extensions/jwt/secrets",
      authentication: .extensionJWT,
      queryItems: { _ in
        [
          ("extension_id", extensionID)
        ]
      },
      responseType: ExtensionSecretsResponse.self,
      makeResponse: { response in
        let secrets = try response.requireFirst()

        return secrets
      })
  }
}

/// The extension secrets returned by Twitch and their version.
public struct ExtensionSecretsResponse: Decodable, Sendable {
  /// The configuration format version.
  public let formatVersion: Int
  /// The extension secrets.
  public let secrets: [ExtensionSecret]

  /// Creates an `ExtensionSecretsResponse` value.
  public init(
    formatVersion: Int,
    secrets: [ExtensionSecret] = []
  ) {
    self.formatVersion = formatVersion
    self.secrets = secrets
  }
}

/// An extension signing secret and its activation and expiration times.
public struct ExtensionSecret: Decodable, Sendable {
  /// The base64-encoded extension secret.
  public let content: String
  /// The time the signing secret becomes valid for signing and verifying JWTs.
  public let activeAt: Date
  /// The time the resource expires.
  public let expiresAt: Date

  /// Creates an `ExtensionSecret` value.
  public init(
    content: String,
    activeAt: Date,
    expiresAt: Date
  ) {
    self.content = content
    self.activeAt = activeAt
    self.expiresAt = expiresAt
  }
}
