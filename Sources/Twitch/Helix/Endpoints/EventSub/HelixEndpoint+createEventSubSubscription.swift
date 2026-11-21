import Foundation

extension HelixEndpoint {
  /// Creates an EventSub subscription using the specified transport.
  ///
  /// WebSocket transport requires a user access token; webhook and conduit transports
  /// require an app access token. Subscription scopes and prior user grants depend on the
  /// event type.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/eventsub/#create-eventsub-subscription
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - transport: The EventSub delivery transport.
  ///   - subscription: The subscription details.
  ///   - isBatchingEnabled: Allows one notification to contain multiple events.
  ///     Currently required to be true only for `drop.entitlement.grant`; all other
  ///     subscription types require false or omission. It does not batch subscriptions.
  ///
  /// - Returns: An endpoint that yields `CreateEventSubSubscriptionResponse` when
  ///   executed.
  public static func createEventSubSubscription(
    using transport: EventSubTransport,
    for subscription: EventSubSubscription<some Event>,
    isBatchingEnabled: Bool? = nil
  ) -> HelixEndpoint<CreateEventSubSubscriptionResponse> {
    createEventSubSubscription(
      using: transport, type: subscription.type, version: subscription.version,
      condition: subscription.condition,
      isBatchingEnabled: isBatchingEnabled)
  }

  internal static func createEventSubSubscription(
    using transport: EventSubTransport,
    type: String, version: String, condition: [String: String],
    isBatchingEnabled: Bool? = nil
  ) -> HelixEndpoint<CreateEventSubSubscriptionResponse> {
    .init(
      method: "POST", path: "eventsub/subscriptions",
      authentication: transport.authentication,
      body: { _ in
        CreateEventSubRequestBody(
          type: type, version: version, condition: condition,
          transport: transport.transport, isBatchingEnabled: isBatchingEnabled)
      },
      responseType: CreateEventSubSubscriptionResponse.Subscription.self,
      makeResponse: {
        let subscription = try $0.requireFirst()

        let total = try $0.require(\.total)
        let totalCost = try $0.require(\.totalCost)
        let maxTotalCost = try $0.require(\.maxTotalCost)

        return CreateEventSubSubscriptionResponse(
          subscription: subscription, total: total, totalCost: totalCost,
          maxTotalCost: maxTotalCost)
      })
  }
}

/// The webhook, WebSocket, or conduit destination for EventSub notifications.
public enum EventSubTransport: Sendable, Equatable {
  /// Delivers notifications to the callback URL using the associated signing secret.
  case webhook(callback: String, secret: String)
  /// Delivers notifications to the associated WebSocket session ID.
  case webSocket(id: String)
  /// Delivers notifications through the associated conduit ID.
  case conduit(id: String)

  internal var authentication: HelixAuthentication {
    switch self {
    case .webSocket: .user
    case .webhook, .conduit: .app
    }
  }

  fileprivate var transport: EventSubTransportPayload {
    switch self {
    case .webhook(let callback, let secret):
      return .init(
        method: "webhook", callback: callback, secret: secret, sessionID: nil,
        conduitID: nil)
    case .webSocket(let sessionID):
      return .init(
        method: "websocket", callback: nil, secret: nil, sessionID: sessionID,
        conduitID: nil)
    case .conduit(let conduitID):
      return .init(
        method: "conduit", callback: nil, secret: nil, sessionID: nil,
        conduitID: conduitID)
    }
  }
}

/// A newly created EventSub subscription and the application’s subscription cost totals.
public struct CreateEventSubSubscriptionResponse: Sendable {
  /// The subscription details.
  public let subscription: Subscription

  /// The number of subscriptions counted by Twitch for this client.
  public let total: Int
  /// The total EventSub subscription cost.
  public let totalCost: Int
  /// The maximum EventSub subscription cost allowed.
  public let maxTotalCost: Int

  /// Creates a `CreateEventSubSubscriptionResponse` value.
  public init(
    subscription: Subscription,
    total: Int,
    totalCost: Int,
    maxTotalCost: Int
  ) {
    self.subscription = subscription
    self.total = total
    self.totalCost = totalCost
    self.maxTotalCost = maxTotalCost
  }

  /// The EventSub subscription created by the request, including its delivery state.
  public struct Subscription: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The subscription’s delivery or verification state.
    public let status: String
    /// The EventSub event name, such as `channel.follow`.
    public let type: String
    /// The EventSub schema version used to decode this subscription’s notifications.
    public let version: String
    /// The conditions selecting which events the subscription receives.
    public var condition: [String: String] { decodedCondition }
    @EventSubCondition private var decodedCondition: [String: String]
    /// The time the resource was created.
    public let createdAt: Date
    /// The EventSub delivery transport.
    public let transport: Transport
    /// The subscription’s contribution to the application’s EventSub cost limit.
    public let cost: Int
    /// Present when notification batching is enabled; omission means false.
    public let isBatchingEnabled: Bool?

    /// Creates a `Subscription` value.
    public init(
      id: String,
      status: String,
      type: String,
      version: String,
      condition: [String: String] = [:],
      createdAt: Date,
      transport: Transport,
      cost: Int,
      isBatchingEnabled: Bool? = nil
    ) {
      self.id = id
      self.status = status
      self.type = type
      self.version = version
      self._decodedCondition = EventSubCondition(wrappedValue: condition)
      self.createdAt = createdAt
      self.transport = transport
      self.cost = cost
      self.isBatchingEnabled = isBatchingEnabled
    }

    private enum CodingKeys: String, CodingKey {
      case id, status, type, version, createdAt, transport, cost, isBatchingEnabled
      case decodedCondition = "condition"
    }
  }

  /// The destination assigned to a newly created EventSub subscription.
  public struct Transport: Decodable, Sendable {
    /// The EventSub delivery method.
    public let method: String

    // only included if method is "webhook"
    /// The webhook callback URL, when provided.
    public let callback: String?
    /// The secret used to authenticate the transport or extension, when provided.
    public let secret: String?

    // only included if method is "websocket"
    /// The identifier of the session, when provided.
    public let sessionID: String?
    /// The time the transport connected, when provided.
    public let connectedAt: Date?

    // only included if method is "conduit"
    /// The identifier of the conduit, when provided.
    public let conduitID: String?

    /// Creates a `Transport` value.
    public init(
      method: String,
      callback: String? = nil,
      secret: String? = nil,
      sessionID: String? = nil,
      connectedAt: Date? = nil,
      conduitID: String? = nil
    ) {
      self.method = method
      self.callback = callback
      self.secret = secret
      self.sessionID = sessionID
      self.connectedAt = connectedAt
      self.conduitID = conduitID
    }

    enum CodingKeys: String, CodingKey {
      case method

      case callback
      case secret

      case sessionID = "sessionId"
      case connectedAt

      case conduitID = "conduitId"
    }
  }
}

struct CreateEventSubRequestBody: Codable, Sendable {
  let type: String
  let version: String
  let condition: [String: String]

  let transport: EventSubTransportPayload
  let isBatchingEnabled: Bool?
}

struct EventSubTransportPayload: Codable, Sendable {
  let method: String
  let callback: String?
  let secret: String?
  let sessionID: String?
  let conduitID: String?

  enum CodingKeys: String, CodingKey {
    case method, callback, secret
    case sessionID = "sessionId"
    case conduitID = "conduitId"
  }
}
