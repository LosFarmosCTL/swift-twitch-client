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
        guard let secrets = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return secrets
      })
  }
}
