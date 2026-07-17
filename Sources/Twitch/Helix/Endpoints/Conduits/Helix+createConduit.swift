import Foundation

extension HelixEndpoint {
  public static func createConduit(
    shardCount: Int
  ) -> HelixEndpoint<Conduit, Conduit, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "eventsub/conduits",
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
