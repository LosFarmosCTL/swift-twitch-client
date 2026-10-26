import Foundation

extension HelixEndpoint {
  /// Deletes an EventSub conduit.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#delete-conduit
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - conduitID: The identifier of the conduit.
  public static func deleteConduit(
    conduitID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "eventsub/conduits",
      queryItems: { _ in
        [
          ("id", conduitID)
        ]
      })
  }
}
