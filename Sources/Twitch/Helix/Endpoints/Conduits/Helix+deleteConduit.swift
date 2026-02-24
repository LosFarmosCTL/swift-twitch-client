import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteConduit(id: String) -> Self {
    .init(
      method: "DELETE", path: "eventsub/conduits",
      queryItems: { _ in
        [
          ("id", id)
        ]
      })
  }
}
