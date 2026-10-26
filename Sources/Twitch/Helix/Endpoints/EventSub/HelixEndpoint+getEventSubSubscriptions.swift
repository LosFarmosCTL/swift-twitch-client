import Foundation
import MemberwiseInit

extension HelixEndpoint {
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

public struct GetEventSubSubscriptionsResponse: Sendable {
  public let subscriptions: [Subscription]

  public let total: Int
  public let totalCost: Int
  public let maxTotalCost: Int

  public let cursor: String?

  @MemberwiseInit(.public)
  public struct Subscription: Decodable, Sendable {
    public let id: String
    public let status: String
    public let type: String
    public let version: String
    public let condition: [String: String]
    public let createdAt: Date
    public let transport: Transport
    public let cost: Int
  }

  @MemberwiseInit(.public)
  public struct Transport: Decodable, Sendable {
    public let method: String

    public let callback: String?
    public let secret: String?

    public let sessionID: String?
    public let connectedAt: Date?
    public let disconnectedAt: Date?

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

public enum EventSubSubscriptionFilter: Sendable {
  case status(EventSubSubscriptionStatus)
  case type(String)
  case userID(String)
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

public enum EventSubSubscriptionStatus: String, Sendable {
  case enabled
  case webhookCallbackVerificationPending = "webhook_callback_verification_pending"
  case webhookCallbackVerificationFailed = "webhook_callback_verification_failed"
  case notificationFailuresExceeded = "notification_failures_exceeded"
  case authorizationRevoked = "authorization_revoked"
  case moderatorRemoved = "moderator_removed"
  case userRemoved = "user_removed"
  case chatUserBanned = "chat_user_banned"
  case versionRemoved = "version_removed"
  case betaMaintenance = "beta_maintenance"
  case webSocketDisconnected = "websocket_disconnected"
  case webSocketFailedPingPong = "websocket_failed_ping_pong"
  case webSocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  case webSocketConnectionUnused = "websocket_connection_unused"
  case webSocketInternalError = "websocket_internal_error"
  case webSocketNetworkTimeout = "websocket_network_timeout"
  case webSocketNetworkError = "websocket_network_error"
  case webSocketFailedToReconnect = "websocket_failed_to_reconnect"
}
