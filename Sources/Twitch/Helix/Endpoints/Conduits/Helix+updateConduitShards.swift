import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ConduitShardUpdateResponse,
  HelixResponseType == ConduitShard
{
  public static func updateConduitShards(
    conduitID: String,
    shards: [ConduitShardUpdate]
  ) -> Self {
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

public struct ConduitShardUpdateResponse: Sendable {
  public let shards: [ConduitShard]
  public let errors: [ConduitShardUpdateError]
}

public struct ConduitShardUpdateError: Sendable {
  public let id: String
  public let message: String
  public let code: String
}

public struct ConduitShardUpdate: Sendable {
  public let id: String
  public let transport: ConduitShardUpdateTransport

  public init(id: String, transport: ConduitShardUpdateTransport) {
    self.id = id
    self.transport = transport
  }
}

public enum ConduitShardUpdateTransport: Sendable {
  case webhook(callback: String, secret: String?)
  case websocket(sessionID: String)

  fileprivate var transport: ConduitShardTransportRequest {
    switch self {
    case .webhook(let callback, let secret):
      return .init(method: "webhook", callback: callback, secret: secret, sessionID: nil)
    case .websocket(let sessionID):
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
