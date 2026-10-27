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
/// The client checks each endpoint’s token kind and token-dependent parameters before
/// sending a request. It does not request additional scopes automatically. Requests use
/// credentials at execution time.
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

  private let authentication: HelixAuthentication
  private let method: String
  private let path: String

  private let makeQueryItems: @Sendable (TwitchCredentials) throws -> [(String, String?)]
  private let makeBody: @Sendable (TwitchCredentials) throws -> Encodable?
  private let makeResponse:
    @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  private let makeRawResponse: @Sendable (Data) throws -> ResponseType

  internal init(
    method: String, path: String,
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil },
    makeResponse:
      @escaping @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  ) {
    self.authentication = authentication
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = makeResponse
    self.makeRawResponse = { _ in fatalError() }
  }

  internal init(
    method: String, path: String,
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil },
    makeRawResponse: @escaping @Sendable (Data) throws -> ResponseType
  ) {
    self.authentication = authentication
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
    try authentication.validate(credentials)
    var url = baseURL.appending(path: path)

    let queryItems =
      try makeQueryItems(credentials).compactMap { (key, value) in
        guard let value else { return nil }
        return URLQueryItem(name: key, value: value)
      } as [URLQueryItem]

    if !queryItems.isEmpty { url = url.appending(queryItems: queryItems) }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    credentials.httpHeaders().forEach({ key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    })

    if let body = try makeBody(credentials) {
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
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil }
  ) {
    // makeResponse should never be called on a Void endpoint!
    self.init(
      method: method, path: path, authentication: authentication, queryItems: queryItems,
      body: body,
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

/// Token requirements are explicit for every factory; Twitch checks scopes and prior grants.
internal enum HelixAuthentication: Sendable {
  case user, app, either, none, extensionJWT

  func validate(_ credentials: TwitchCredentials) throws {
    switch self {
    case .user: _ = try credentials.requireUser()
    case .app:
      guard credentials.kind == .app else {
        throw TwitchAuthenticationError.appAccessTokenRequired
      }
    case .extensionJWT:
      guard credentials.kind == .extensionJWT else {
        throw TwitchAuthenticationError.extensionJWTRequired
      }
    case .either:
      guard credentials.kind != .extensionJWT else {
        throw TwitchAuthenticationError.oauthAccessTokenRequired
      }
    case .none: break
    }
  }
}
