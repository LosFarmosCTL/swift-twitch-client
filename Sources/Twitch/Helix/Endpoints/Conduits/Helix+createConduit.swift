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
        guard let conduit = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return conduit
      })
  }
}

private struct CreateConduitRequest: Encodable, Sendable {
  let shardCount: Int
}
