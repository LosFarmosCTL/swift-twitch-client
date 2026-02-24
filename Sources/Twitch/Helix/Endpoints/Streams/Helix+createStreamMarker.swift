import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == StreamMarker,
  HelixResponseType == StreamMarker
{
  public static func createStreamMarker(
    for userID: UserID? = nil,
    description: String? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "streams/markers",
      body: { auth in
        CreateStreamMarkerRequestBody(
          userID: userID ?? auth.userID,
          description: description)
      },
      makeResponse: { response in
        guard let marker = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return marker
      })
  }
}

private struct CreateStreamMarkerRequestBody: Encodable, Sendable {
  let userID: String
  let description: String?
}

public struct StreamMarker: Decodable, Sendable {
  public let id: String
  public let createdAt: Date
  public let positionSeconds: Int
  public let description: String
}
