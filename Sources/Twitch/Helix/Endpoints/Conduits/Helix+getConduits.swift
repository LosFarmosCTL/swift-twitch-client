import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Conduit], HelixResponseType == Conduit
{
  public static func getConduits() -> Self {
    .init(
      method: "GET", path: "eventsub/conduits",
      makeResponse: { $0.data })
  }
}

public struct Conduit: Decodable, Sendable {
  public let id: String
  public let shardCount: Int
}
