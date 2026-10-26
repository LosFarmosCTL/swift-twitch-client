import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getConduitShards(
    conduitID: String,
    status: ConduitShardStatus? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (shards: [ConduitShard], cursor: String?),
    ConduitShard, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "eventsub/conduits/shards",
      queryItems: { _ in
        [
          ("conduit_id", conduitID),
          ("status", status?.rawValue),
          ("after", afterCursor),
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
  case webSocketDisconnected = "websocket_disconnected"
  case webSocketFailedPingPong = "websocket_failed_ping_pong"
  case webSocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  case webSocketInternalError = "websocket_internal_error"
  case webSocketNetworkTimeout = "websocket_network_timeout"
  case webSocketNetworkError = "websocket_network_error"
  case webSocketFailedToReconnect = "websocket_failed_to_reconnect"
}

@MemberwiseInit(.public)
public struct ConduitShard: Decodable, Sendable {
  public let id: String
  public let status: String
  public let transport: ConduitShardTransport
}

@MemberwiseInit(.public)
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
