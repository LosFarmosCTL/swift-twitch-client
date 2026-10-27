import Foundation

extension HelixEndpoint {
  /// Changes an EventSub conduit’s shard count.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-conduits
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - conduitID: The identifier of the conduit.
  ///   - shardCount: The number of shards assigned to the conduit.
  public static func updateConduit(
    conduitID: String,
    shardCount: Int
  ) -> HelixEndpoint<Conduit, Conduit, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "eventsub/conduits",
      authentication: .app,
      body: { _ in
        UpdateConduitRequest(id: conduitID, shardCount: shardCount)
      },
      makeResponse: {
        let conduit = try $0.requireFirst()

        return conduit
      })
  }
}

private struct UpdateConduitRequest: Encodable, Sendable {
  let id: String
  let shardCount: Int
}
