import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([ConduitShard], String?),
  HelixResponseType == ConduitShard
{
  public static func getConduitShards(
    conduitID: String,
    status: ConduitShardStatus? = nil,
    after cursor: String? = nil
  ) -> Self {
    .init(
      method: "GET", path: "eventsub/conduits/shards",
      queryItems: { _ in
        [
          ("conduit_id", conduitID),
          ("status", status?.rawValue),
          ("after", cursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public enum ConduitShardStatus: String, Sendable {
  case enabled
  case webhookCallbackVerificationPending = "webhook_callback_verification_pending"
  case webhookCallbackVerificationFailed = "webhook_callback_verification_failed"
  case notificationFailuresExceeded = "notification_failures_exceeded"
  case websocketDisconnected = "websocket_disconnected"
  case websocketFailedPingPong = "websocket_failed_ping_pong"
  case websocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  case websocketInternalError = "websocket_internal_error"
  case websocketNetworkTimeout = "websocket_network_timeout"
  case websocketNetworkError = "websocket_network_error"
  case websocketFailedToReconnect = "websocket_failed_to_reconnect"
}

public struct ConduitShard: Decodable, Sendable {
  public let id: String
  public let status: String
  public let transport: ConduitShardTransport
}

public struct ConduitShardTransport: Decodable, Sendable {
  public let method: String
  public let callback: String?
  public let sessionID: String?
  public let connectedAt: Date?
  public let disconnectedAt: Date?

  enum CodingKeys: String, CodingKey {
    case method, callback
    case sessionID = "sessionId"
    case connectedAt, disconnectedAt
  }
}
