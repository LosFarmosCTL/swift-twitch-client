import Foundation

extension HelixEndpoint {
  public static func deleteEventSubSubscription(subscriptionID: String) -> HelixEndpoint<
    EmptyResponse, EmptyResponse,
    HelixEndpointResponseTypes.Void
  > {
    .init(
      method: "DELETE", path: "eventsub/subscriptions",
      queryItems: { _ in
        [("id", subscriptionID)]
      })
  }
}
