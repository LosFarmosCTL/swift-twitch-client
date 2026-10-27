import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets EventSub subscriptions matching the supplied filters.
  ///
  /// WebSocket transport requires a user access token; webhook and conduit transports
  /// require an app access token. Subscription scopes and prior user grants depend on the
  /// event type.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-eventsub-subscriptions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - filter: The subscription filter; `nil` requests subscriptions without this
  ///     filter.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  public static func getEventSubSubscriptions(
    filter: EventSubSubscriptionFilter? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    GetEventSubSubscriptionsResponse,
    GetEventSubSubscriptionsResponse.Subscription,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "eventsub/subscriptions",
      authentication: .either,
      queryItems: { _ in
        var items: [(String, String?)] = []

        if let filter {
          items.append(filter.queryItem)
        }

        items.append(("after", afterCursor))
        return items
      },
      makeResponse: { response in
        let total = try response.require(\.total)
        let totalCost = try response.require(\.totalCost)
        let maxTotalCost = try response.require(\.maxTotalCost)

        return GetEventSubSubscriptionsResponse(
          subscriptions: response.data,
          total: total,
          totalCost: totalCost,
          maxTotalCost: maxTotalCost,
          cursor: response.pagination?.cursor)
      })
  }
}

/// A page of EventSub subscriptions, cost totals, and the next pagination cursor.
public struct GetEventSubSubscriptionsResponse: Sendable {
  /// The EventSub subscriptions.
  public let subscriptions: [Subscription]

  /// The number of subscriptions matching the request across all pages.
  public let total: Int
  /// The total EventSub subscription cost.
  public let totalCost: Int
  /// The maximum EventSub subscription cost allowed.
  public let maxTotalCost: Int

  /// The pagination cursor to pass when requesting another page.
  public let cursor: String?

  /// An existing EventSub subscription’s conditions, destination, and delivery state.
  @MemberwiseInit(.public)
  public struct Subscription: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The subscription’s delivery or revocation state.
    public let status: String
    /// The EventSub event name, such as `channel.follow`.
    public let type: String
    /// The EventSub schema version used to decode this subscription’s notifications.
    public let version: String
    /// The conditions selecting which events the subscription receives.
    public let condition: [String: String]
    /// The time the resource was created.
    public let createdAt: Date
    /// The EventSub delivery transport.
    public let transport: Transport
    /// The subscription’s contribution to the application’s EventSub cost limit.
    public let cost: Int
  }

  /// An existing subscription’s destination and WebSocket connection timestamps.
  @MemberwiseInit(.public)
  public struct Transport: Decodable, Sendable {
    /// The EventSub delivery method.
    public let method: String

    /// The webhook callback URL, when provided.
    public let callback: String?
    /// The secret used to authenticate the transport or extension, when provided.
    public let secret: String?

    /// The identifier of the session, when provided.
    public let sessionID: String?
    /// The time the transport connected, when provided.
    public let connectedAt: Date?
    /// The time the transport disconnected, when provided.
    public let disconnectedAt: Date?

    /// The identifier of the conduit, when provided.
    public let conduitID: String?

    enum CodingKeys: String, CodingKey {
      case method

      case callback
      case secret

      case sessionID = "sessionId"
      case connectedAt
      case disconnectedAt

      case conduitID = "conduitId"
    }
  }
}

/// A single criterion used to select EventSub subscriptions.
public enum EventSubSubscriptionFilter: Sendable {
  /// Includes subscriptions with the specified delivery or revocation status.
  case status(EventSubSubscriptionStatus)
  /// Includes subscriptions for an event type, such as `channel.follow`.
  case type(String)
  /// Includes subscriptions whose conditions contain the specified Twitch user ID.
  case userID(String)
  /// Selects the subscription with the specified ID.
  case subscriptionID(String)

  fileprivate var queryItem: (String, String?) {
    switch self {
    case .status(let status):
      return ("status", status.rawValue)
    case .type(let type):
      return ("type", type)
    case .userID(let userID):
      return ("user_id", userID)
    case .subscriptionID(let subscriptionID):
      return ("subscription_id", subscriptionID)
    }
  }
}

/// An EventSub subscription’s delivery, verification, or revocation state.
public enum EventSubSubscriptionStatus: String, Sendable {
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
  /// Authorization for the subscription was revoked. Encoded as
  /// `"authorization_revoked"`.
  case authorizationRevoked = "authorization_revoked"
  /// The user no longer has the required moderator role. Encoded as
  /// `"moderator_removed"`.
  case moderatorRemoved = "moderator_removed"
  /// The subscribed user was removed. Encoded as `"user_removed"`.
  case userRemoved = "user_removed"
  /// The chat user was banned from the channel. Encoded as `"chat_user_banned"`.
  case chatUserBanned = "chat_user_banned"
  /// Twitch removed the subscription schema version. Encoded as `"version_removed"`.
  case versionRemoved = "version_removed"
  /// The event type is undergoing beta maintenance. Encoded as `"beta_maintenance"`.
  case betaMaintenance = "beta_maintenance"
  /// The WebSocket connection disconnected. Encoded as `"websocket_disconnected"`.
  case webSocketDisconnected = "websocket_disconnected"
  /// The WebSocket did not complete a ping/pong exchange. Encoded as
  /// `"websocket_failed_ping_pong"`.
  case webSocketFailedPingPong = "websocket_failed_ping_pong"
  /// Twitch received unsupported inbound WebSocket traffic. Encoded as
  /// `"websocket_received_inbound_traffic"`.
  case webSocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  /// The WebSocket had no active subscriptions within the required time. Encoded as
  /// `"websocket_connection_unused"`.
  case webSocketConnectionUnused = "websocket_connection_unused"
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
