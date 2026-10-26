import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A typed description of a Helix request and its response conversion.
///
/// Use the static endpoint factories to select an operation and provide request
/// parameters. Creating an endpoint performs no network I/O. Execute it with a
/// `helix(for:)` overload on ``TwitchClient``.
///
/// `ResponseType` is the caller-facing result, `HelixResponseType` is the decoded payload
/// element, and `EndpointResponseType` selects empty, JSON, or raw response handling.
///
/// Factories document Twitch’s token and scope requirements; the client does not request
/// additional scopes automatically. The request uses credentials at execution time.
/// Twitch also enforces the linked reference’s account eligibility, parameter limits, and
/// token ownership rules.
///
/// A successful HTTP response may still report an operation-specific failure, such as a
/// chat message rejected for delivery. Check the returned model’s status fields.
public struct HelixEndpoint<
  ResponseType, HelixResponseType: Sendable & Decodable,
  EndpointResponseType: HelixEndpointResponseType
>: Sendable {
  private let baseURL = URL(string: "https://api.twitch.tv/helix")!

  private let method: String
  private let path: String

  private let makeQueryItems: @Sendable (TwitchCredentials) -> [(String, String?)]
  private let makeBody: @Sendable (TwitchCredentials) -> Encodable?
  private let makeResponse:
    @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  private let makeRawResponse: @Sendable (Data) throws -> ResponseType

  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil },
    makeResponse:
      @escaping @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  ) {
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = makeResponse
    self.makeRawResponse = { _ in fatalError() }
  }

  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil },
    makeRawResponse: @escaping @Sendable (Data) throws -> ResponseType
  ) {
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = { _ in fatalError() }
    self.makeRawResponse = makeRawResponse
  }

  internal func makeRequest(
    using credentials: TwitchCredentials,
    encoder: JSONEncoder
  ) throws -> URLRequest {
    var url = baseURL.appending(path: path)

    let queryItems =
      makeQueryItems(credentials).compactMap { (key, value) in
        guard let value else { return nil }
        return URLQueryItem(name: key, value: value)
      } as [URLQueryItem]

    if !queryItems.isEmpty { url = url.appending(queryItems: queryItems) }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    credentials.httpHeaders().forEach({ key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    })

    if let body = makeBody(credentials) {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try encoder.encode(body)
    }

    return urlRequest
  }

  internal func makeResponse(from response: HelixResponse<HelixResponseType>) throws
    -> ResponseType
  {
    try makeResponse(response)
  }

  internal func makeResponse(from data: Data) throws -> ResponseType {
    try makeRawResponse(data)
  }
}

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil }
  ) {
    // makeResponse should never be called on a Void endpoint!
    self.init(
      method: method, path: path, queryItems: queryItems, body: body,
      makeResponse: { _ in fatalError() })
  }
}

/// A marker protocol selecting how a Helix response is processed.
public protocol HelixEndpointResponseType: SendableMetatype {}
/// The response-processing markers used by ``HelixEndpoint``.
public enum HelixEndpointResponseTypes {
  /// A marker for endpoints that require an empty response body.
  public enum Void: HelixEndpointResponseType {}
  /// A marker for endpoints that decode the Helix JSON response envelope.
  public enum Normal: HelixEndpointResponseType {}
  /// A marker for endpoints that convert the response body without a Helix JSON envelope.
  public enum Raw: HelixEndpointResponseType {}
}
