import Foundation

extension HelixEndpoint {
  /// Creates an EventSub conduit with the requested shard count.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-conduits
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - shardCount: The number of shards assigned to the conduit.
  public static func createConduit(
    shardCount: Int
  ) -> HelixEndpoint<Conduit, Conduit, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "eventsub/conduits",
      authentication: .app,
      body: { _ in
        CreateConduitRequest(shardCount: shardCount)
      },
      makeResponse: {
        let conduit = try $0.requireFirst()

        return conduit
      })
  }
}

private struct CreateConduitRequest: Encodable, Sendable {
  let shardCount: Int
}
