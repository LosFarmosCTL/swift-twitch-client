import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GetEventSubSubscriptionsResponse,
  HelixResponseType == GetEventSubSubscriptionsResponse.EventSubSubscription
{
  public static func getEventSubSubscriptions(
    filter: EventSubSubscriptionFilter? = nil,
    after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "eventsub/subscriptions",
      queryItems: { _ in
        var items: [(String, String?)] = []

        if let filter {
          items.append(filter.queryItem)
        }

        items.append(("after", cursor))
        return items
      },
      makeResponse: { response in
        guard let total = response.total,
          let totalCost = response.totalCost,
          let maxTotalCost = response.maxTotalCost
        else {
          throw HelixError.missingDataInResponse(responseData: response.rawData)
        }

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
  public let subscriptions: [EventSubSubscription]

  public let total: Int
  public let totalCost: Int
  public let maxTotalCost: Int

  public let cursor: String?

  public struct EventSubSubscription: Decodable, Sendable {
    public let id: String
    public let status: String
    public let type: String
    public let version: String
    public let condition: [String: String]
    public let createdAt: Date
    public let transport: TransportResponse
    public let cost: Int
  }

  public struct TransportResponse: Decodable, Sendable {
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
  case websocketDisconnected = "websocket_disconnected"
  case websocketFailedPingPong = "websocket_failed_ping_pong"
  case websocketReceivedInboundTraffic = "websocket_received_inbound_traffic"
  case websocketConnectionUnused = "websocket_connection_unused"
  case websocketInternalError = "websocket_internal_error"
  case websocketNetworkTimeout = "websocket_network_timeout"
  case websocketNetworkError = "websocket_network_error"
  case websocketFailedToReconnect = "websocket_failed_to_reconnect"
}
