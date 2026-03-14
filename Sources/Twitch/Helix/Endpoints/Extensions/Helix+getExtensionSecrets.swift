import Foundation
import MemberwiseInit

extension HelixEndpoint {
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
        guard let secrets = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return secrets
      })
  }
}

@MemberwiseInit(.public)
public struct ExtensionSecretsResponse: Decodable, Sendable {
  public let formatVersion: Int
  public let secrets: [ExtensionSecret]
}

@MemberwiseInit(.public)
public struct ExtensionSecret: Decodable, Sendable {
  public let content: String
  public let activeAt: Date
  public let expiresAt: Date
}
