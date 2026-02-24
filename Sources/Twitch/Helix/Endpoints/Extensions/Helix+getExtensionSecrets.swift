import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ExtensionSecretsResponse, HelixResponseType == ExtensionSecretsResponse
{
  public static func getExtensionSecrets(extensionID: String) -> Self {
    return .init(
      method: "GET", path: "extensions/jwt/secrets",
      queryItems: { _ in
        [
          ("extension_id", extensionID)
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

public struct ExtensionSecretsResponse: Decodable, Sendable {
  public let formatVersion: Int
  public let secrets: [ExtensionSecret]
}

public struct ExtensionSecret: Decodable, Sendable {
  public let content: String
  public let activeAt: Date
  public let expiresAt: Date
}
