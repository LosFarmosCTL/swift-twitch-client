import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == CreateEventSubResponse,
  HelixResponseType == CreateEventSubResponse.EventSubSubscription
{
  public static func createEventSubSubscription(
    using transport: EventSubTransport, type: EventSubSubscription<some Event>
  ) -> Self {
    .init(
      method: "POST", path: "eventsub/subscriptions",
      body: { _ in
        CreateEventSubRequestBody(
          type: type.type, version: type.version, condition: type.condition,
          transport: transport.transport)
      },
      makeResponse: {
        guard let subscription = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        guard let total = $0.total,
          let totalCost = $0.totalCost,
          let maxTotalCost = $0.maxTotalCost
        else {
          throw HelixError.missingDataInResponse
        }

        return CreateEventSubResponse(
          subscription: subscription, total: total, totalCost: totalCost,
          maxTotalCost: maxTotalCost)
      })
  }
}

public enum EventSubTransport: Sendable {
  case webhook(callback: String, secret: String)
  case websocket(id: String)
  case conduit(id: String)

  fileprivate var transport: Transport {
    switch self {
    case .webhook(let callback, let secret):
      return .init(
        method: "webhook", callback: callback, secret: secret, sessionID: nil,
        conduitID: nil)
    case .websocket(let id):
      return .init(
        method: "websocket", callback: nil, secret: nil, sessionID: id, conduitID: nil)
    case .conduit(let id):
      return .init(
        method: "conduit", callback: nil, secret: nil, sessionID: nil, conduitID: id)
    }
  }
}

public struct CreateEventSubResponse: Sendable {
  public let subscription: EventSubSubscription

  public let total: Int
  public let totalCost: Int
  public let maxTotalCost: Int

  public struct EventSubSubscription: Decodable, Sendable {
    public let id: String
    public let status: String
    public let type: String
    public let version: String
    public let condition: [String: String]
    public let createdAt: Date
    public let transport: TransportResponse
  }

  public struct TransportResponse: Decodable, Sendable {
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

private struct CreateEventSubRequestBody: Encodable, Sendable {
  let type: String
  let version: String
  let condition: [String: String]

  let transport: Transport
}

private struct Transport: Encodable, Sendable {
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
