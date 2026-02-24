import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ExtensionSecretsResponse, HelixResponseType == ExtensionSecretsResponse
{
  public static func createExtensionSecret(
    extensionID: String,
    delay: Int? = nil
  ) -> Self {
    return .init(
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
