import Foundation

extension HelixEndpoint {
  public static func updateConduit(
    conduitID: String,
    shardCount: Int
  ) -> HelixEndpoint<Conduit, Conduit, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "eventsub/conduits",
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
