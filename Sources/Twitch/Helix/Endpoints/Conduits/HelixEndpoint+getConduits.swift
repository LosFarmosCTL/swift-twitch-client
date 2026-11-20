import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the application’s EventSub conduits.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-conduits
  /// ) for request limits and account requirements.
  public static func getConduits()
    -> HelixEndpoint<[Conduit]>
  {
    .init(
      method: "GET", path: "eventsub/conduits",
      authentication: .app,
      responseType: Conduit.self, makeResponse: { $0.data })
  }
}

/// An EventSub conduit and its configured shard count.
@MemberwiseInit(.public)
public struct Conduit: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The number of shards assigned to the conduit.
  public let shardCount: Int
}
