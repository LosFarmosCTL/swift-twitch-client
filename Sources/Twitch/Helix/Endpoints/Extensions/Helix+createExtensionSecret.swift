import Foundation

extension HelixEndpoint {
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
