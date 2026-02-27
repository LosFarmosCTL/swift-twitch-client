import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteEventSubSubscription(id: String) -> Self {
    return .init(
      method: "DELETE", path: "eventsub/subscriptions",
      queryItems: { _ in
        [
          ("id", id)
        ]
      })
  }
}
