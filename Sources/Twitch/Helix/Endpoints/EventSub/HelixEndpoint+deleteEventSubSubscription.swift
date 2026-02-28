import Foundation

extension HelixEndpoint {
  public static func deleteEventSubSubscription(id: String) -> HelixEndpoint<
    EmptyResponse, EmptyResponse,
    HelixEndpointResponseTypes.Void
  > {
    .init(
      method: "DELETE", path: "eventsub/subscriptions",
      queryItems: { _ in
        [("id", id)]
      })
  }
}
