import Foundation

extension HelixEndpoint {
  /// Updates the transports assigned to EventSub conduit shards.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-conduit-shards
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - conduitID: The identifier of the conduit.
  ///   - shards: The shard configurations to apply.
  public static func updateConduitShards(
    conduitID: String,
    shards: [ConduitShardUpdate]
  ) -> HelixEndpoint<
    ConduitShardUpdateResponse, ConduitShard,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PATCH", path: "eventsub/conduits/shards",
      body: { _ in
        UpdateConduitShardsRequest(
          conduitID: conduitID,
          shards: shards.map { shard in
            ConduitShardUpdateRequest(
              id: shard.id,
              transport: shard.transport.transport)
          })
      },
      makeResponse: {
        ConduitShardUpdateResponse(
          shards: $0.data,
          errors: ($0.errors ?? []).map { error in
            ConduitShardUpdateError(
              id: error.id,
              message: error.message,
              code: error.code)
          })
      })
  }
}

/// The shards updated successfully and the per-shard errors from the same request.
public struct ConduitShardUpdateResponse: Sendable {
  /// The conduit shards.
  public let shards: [ConduitShard]
  /// The per-item errors.
  public let errors: [ConduitShardUpdateError]
}

/// The failure code and explanation for one shard that could not be updated.
public struct ConduitShardUpdateError: Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The message content or explanatory text supplied by Twitch.
  public let message: String
  /// The Twitch error code for the shard update.
  public let code: String
}

/// The shard ID and destination to include in a conduit update request.
public struct ConduitShardUpdate: Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The EventSub delivery transport.
  public let transport: ConduitShardUpdateTransport

  /// Creates a conduit shard update value.
  ///
  /// - Parameters:
  ///   - id: The identifier assigned by Twitch.
  ///   - transport: The EventSub delivery transport.
  public init(id: String, transport: ConduitShardUpdateTransport) {
    self.id = id
    self.transport = transport
  }
}

/// The webhook or WebSocket destination to assign to a conduit shard.
public enum ConduitShardUpdateTransport: Sendable {
  /// Delivers notifications to the callback URL using the associated signing secret.
  case webhook(callback: String, secret: String?)
  /// Delivers notifications to the associated WebSocket session ID.
  case webSocket(id: String)

  fileprivate var transport: ConduitShardTransportRequest {
    switch self {
    case .webhook(let callback, let secret):
      return .init(method: "webhook", callback: callback, secret: secret, sessionID: nil)
    case .webSocket(let sessionID):
      return .init(method: "websocket", callback: nil, secret: nil, sessionID: sessionID)
    }
  }
}

private struct UpdateConduitShardsRequest: Encodable, Sendable {
  let conduitID: String
  let shards: [ConduitShardUpdateRequest]
}

private struct ConduitShardUpdateRequest: Encodable, Sendable {
  let id: String
  let transport: ConduitShardTransportRequest
}

private struct ConduitShardTransportRequest: Encodable, Sendable {
  let method: String
  let callback: String?
  let secret: String?
  let sessionID: String?

  enum CodingKeys: String, CodingKey {
    case method, callback, secret
    case sessionID = "sessionId"
  }
}
