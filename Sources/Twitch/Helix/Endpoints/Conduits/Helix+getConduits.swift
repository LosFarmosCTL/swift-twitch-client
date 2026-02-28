import Foundation

extension HelixEndpoint {
  public static func getConduits()
    -> HelixEndpoint<[Conduit], Conduit, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "eventsub/conduits",
      makeResponse: { $0.data })
  }
}

public struct Conduit: Decodable, Sendable {
  public let id: String
  public let shardCount: Int
}
