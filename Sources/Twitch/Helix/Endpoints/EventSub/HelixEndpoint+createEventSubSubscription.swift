import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func createEventSubSubscription(
    using transport: EventSubTransport, for subscription: EventSubSubscription<some Event>
  ) -> HelixEndpoint<
    CreateEventSubSubscriptionResponse,
    CreateEventSubSubscriptionResponse.Subscription,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "eventsub/subscriptions",
      body: { _ in
        CreateEventSubRequestBody(
          type: subscription.type, version: subscription.version,
          condition: subscription.condition,
          transport: transport.transport)
      },
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

public enum EventSubTransport: Sendable {
  case webhook(callback: String, secret: String)
  case webSocket(id: String)
  case conduit(id: String)

  fileprivate var transport: EventSubTransportPayload {
    switch self {
    case .webhook(let callback, let secret):
      return .init(
        method: "webhook", callback: callback, secret: secret, sessionID: nil,
        conduitID: nil)
    case .webSocket(let sessionID):
      return .init(
        method: "websocket", callback: nil, secret: nil, sessionID: sessionID, conduitID: nil)
    case .conduit(let conduitID):
      return .init(
        method: "conduit", callback: nil, secret: nil, sessionID: nil, conduitID: conduitID)
    }
  }
}

public struct CreateEventSubSubscriptionResponse: Sendable {
  public let subscription: Subscription

  public let total: Int
  public let totalCost: Int
  public let maxTotalCost: Int

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

    // only included if method is "webhook"
    public let callback: String?
    public let secret: String?

    // only included if method is "websocket"
    public let sessionID: String?
    public let connectedAt: Date?

    // only included if method is "conduit"
    public let conduitID: String?

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
