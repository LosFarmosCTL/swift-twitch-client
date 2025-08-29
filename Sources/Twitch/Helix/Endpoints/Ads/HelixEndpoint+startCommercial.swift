import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Commercial, HelixResponseType == Commercial
{
  public static func startCommercial(length: Int) -> Self {
    .init(
      method: "POST", path: "channels/commercial",
      body: { auth in
        StartCommercialRequestBody(broadcasterID: auth.userID, length: length)
      },
      makeResponse: { result in
        guard let response = result.data.first else {
          throw HelixError.noDataInResponse
        }

        return response
      })
  }
}

private struct StartCommercialRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let length: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case length
  }
}

public struct Commercial: Decodable, Sendable {
  public let length: Int
  public let message: String
  public let retryAfter: Int
}
