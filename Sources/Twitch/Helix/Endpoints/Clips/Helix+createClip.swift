import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ClipCreation, HelixResponseType == ClipCreation
{
  public static func createClip(
    broadcasterID: UserID? = nil,
    title: String? = nil,
    duration: Double? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "clips",
      queryItems: { auth in
        return [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("title", title),
          ("duration", duration.map(String.init(describing:))),
        ]
      },
      makeResponse: {
        guard let clip = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return clip
      })
  }
}

public struct ClipCreation: Decodable, Sendable {
  public let id: String
  public let editURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case editURL = "editUrl"
  }
}
