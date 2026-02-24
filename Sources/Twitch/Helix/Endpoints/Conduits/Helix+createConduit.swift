import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Conduit, HelixResponseType == Conduit
{
  public static func createConduit(shardCount: Int) -> Self {
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
