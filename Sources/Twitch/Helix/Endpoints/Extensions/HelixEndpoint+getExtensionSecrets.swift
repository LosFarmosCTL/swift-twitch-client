import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets an extension’s signing secrets and their validity periods.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Supply the signed JWT as `TwitchCredentials.accessToken` and the extension’s client ID
  /// as `clientID`. The client sends the JWT as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-secrets
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  public static func getExtensionSecrets(
    extensionID: String
  ) -> HelixEndpoint<
    ExtensionSecretsResponse, ExtensionSecretsResponse,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "extensions/jwt/secrets",
      queryItems: { _ in
        [
          ("extension_id", extensionID)
        ]
      },
      makeResponse: { response in
        let secrets = try response.requireFirst()

        return secrets
      })
  }
}

/// The extension secrets returned by Twitch and their version.
@MemberwiseInit(.public)
public struct ExtensionSecretsResponse: Decodable, Sendable {
  /// The configuration format version.
  public let formatVersion: Int
  /// The extension secrets.
  public let secrets: [ExtensionSecret]
}

/// An extension signing secret and its activation and expiration times.
@MemberwiseInit(.public)
public struct ExtensionSecret: Decodable, Sendable {
  /// The base64-encoded extension secret.
  public let content: String
  /// The time the signing secret becomes valid for signing and verifying JWTs.
  public let activeAt: Date
  /// The time the resource expires.
  public let expiresAt: Date
}
