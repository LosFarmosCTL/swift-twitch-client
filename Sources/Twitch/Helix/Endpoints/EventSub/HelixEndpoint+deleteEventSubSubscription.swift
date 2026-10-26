import Foundation

extension HelixEndpoint {
  /// Deletes an EventSub subscription.
  ///
  /// WebSocket transport requires a user access token; webhook and conduit transports
  /// require an app access token. Subscription scopes and prior user grants depend on the
  /// event type.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-eventsub-subscription
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - subscriptionID: The identifier of the subscription.
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
