import Foundation

extension HelixEndpoint {
  public static func updateConduit(
    id: String,
    shardCount: Int
  ) -> HelixEndpoint<Conduit, Conduit, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "eventsub/conduits",
      body: { _ in
        UpdateConduitRequest(id: id, shardCount: shardCount)
      },
      makeResponse: {
        guard let conduit = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return conduit
      })
  }
}

private struct UpdateConduitRequest: Encodable, Sendable {
  let id: String
  let shardCount: Int
}
