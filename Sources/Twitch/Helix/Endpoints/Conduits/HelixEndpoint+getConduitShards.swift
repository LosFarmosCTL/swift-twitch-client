import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the shards and transport state of an EventSub conduit.
  ///
  /// Twitch requires an app access token for this endpoint.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-conduit-shards
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - conduitID: The identifier of the conduit.
  ///   - status: The requested status or status filter.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(shards: [ConduitShard], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
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

/// The delivery and connection states available when filtering conduit shards.
public enum ConduitShardStatus: String, Sendable {
  /// The subscription or shard is enabled and can deliver notifications.
  case enabled
  /// Twitch is waiting to verify the webhook callback. Encoded as
  /// `"webhook_callback_verification_pending"`.
  case webhookCallbackVerificationPending = "webhook_callback_verification_pending"
  /// The webhook callback could not be verified. Encoded as
  /// `"webhook_callback_verification_failed"`.
  case webhookCallbackVerificationFailed = "webhook_callback_verification_failed"
  /// Repeated notification delivery failures disabled delivery. Encoded as
  /// `"notification_failures_exceeded"`.
  case notificationFailuresExceeded = "notification_failures_exceeded"
  /// The WebSocket connection disconnected. Encoded as `"websocket_disconnected"`.
  case webSocketDisconnected = "websocket_disconnected"
  /// The WebSocket did not complete a ping/pong exchange. Encoded as
  /// `"websocket_failed_ping_pong"`.
  case webSocketFailedPingPong = "websocket_failed_ping_pong"
  /// Twitch received unsupported inbound WebSocket traffic. Encoded as
  /// `"websocket_received_inbound_traffic"`.
  case webSocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  /// The WebSocket closed because of an internal error. Encoded as
  /// `"websocket_internal_error"`.
  case webSocketInternalError = "websocket_internal_error"
  /// The WebSocket network operation timed out. Encoded as `"websocket_network_timeout"`.
  case webSocketNetworkTimeout = "websocket_network_timeout"
  /// The WebSocket encountered a network error. Encoded as `"websocket_network_error"`.
  case webSocketNetworkError = "websocket_network_error"
  /// The WebSocket did not reconnect successfully. Encoded as
  /// `"websocket_failed_to_reconnect"`.
  case webSocketFailedToReconnect = "websocket_failed_to_reconnect"
}

/// An EventSub conduit shard and its delivery status and transport.
@MemberwiseInit(.public)
public struct ConduitShard: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The shard transport’s connection or delivery state.
  public let status: String
  /// The EventSub delivery transport.
  public let transport: ConduitShardTransport
}

/// The delivery transport assigned to an EventSub conduit shard.
@MemberwiseInit(.public)
public struct ConduitShardTransport: Decodable, Sendable {
  /// The EventSub delivery method.
  public let method: String
  /// The webhook callback URL, when provided.
  public let callback: String?
  /// The identifier of the session, when provided.
  public let sessionID: String?
  /// The time the transport connected, when provided.
  public let connectedAt: Date?
  /// The time the transport disconnected, when provided.
  public let disconnectedAt: Date?

  enum CodingKeys: String, CodingKey {
    case method, callback
    case sessionID = "sessionId"
    case connectedAt, disconnectedAt
  }
}
