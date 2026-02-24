import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [String], HelixResponseType == String
{
  public static func deleteVideos(ids: [String]) -> Self {
    return .init(
      method: "DELETE", path: "videos",
      queryItems: { _ in
        ids.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}
