import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func cancelRaid() -> Self {
    .init(
      method: "DELETE", path: "raids",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      })
  }
}
