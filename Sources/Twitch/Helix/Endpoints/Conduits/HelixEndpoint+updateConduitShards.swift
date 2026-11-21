import Foundation

extension HelixEndpoint {
  /// Updates the transports assigned to EventSub conduit shards.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/conduits/#update-conduit-shards
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - conduitID: The identifier of the conduit.
  ///   - shards: The shard configurations to apply, up to 100 per request.
  public static func updateConduitShards(
    conduitID: String,
    shards: [ConduitShardUpdate]
  ) -> HelixEndpoint<ConduitShardUpdateResponse> {
    .init(
      method: "PATCH", path: "eventsub/conduits/shards",
      authentication: .app,
      body: { _ in
        UpdateConduitShardsRequest(
          conduitID: conduitID,
          shards: shards.map { shard in
            ConduitShardUpdateRequest(
              id: shard.id,
              transport: shard.transport.transport)
          })
      },
      responseType: ConduitShard.self,
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

  /// Creates a `ConduitShardUpdateResponse` value.
  public init(
    shards: [ConduitShard] = [],
    errors: [ConduitShardUpdateError] = []
  ) {
    self.shards = shards
    self.errors = errors
  }
}

/// The failure code and explanation for one shard that could not be updated.
public struct ConduitShardUpdateError: Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// Twitch's explanation of why updating this shard failed.
  public let message: String
  /// The Twitch error code for the shard update.
  public let code: String

  /// Creates a `ConduitShardUpdateError` value.
  public init(
    id: String,
    message: String,
    code: String
  ) {
    self.id = id
    self.message = message
    self.code = code
  }
}

/// The shard ID and destination to include in a conduit update request.
public struct ConduitShardUpdate: Sendable, Equatable {
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
public enum ConduitShardUpdateTransport: Sendable, Equatable {
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
