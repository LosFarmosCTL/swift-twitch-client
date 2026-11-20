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
/// `Response` is the caller-facing value inside ``HelixResponse``. Payload decoding and
/// empty-body or raw-body handling are implementation details of the selected factory.
///
/// The client checks each endpoint’s token kind and token-dependent parameters before
/// sending a request. It does not request additional scopes automatically. Requests use
/// credentials at execution time.
/// Twitch also enforces the linked reference’s account eligibility, parameter limits, and
/// token ownership rules.
///
/// A successful HTTP response may still report an operation-specific failure, such as a
/// chat message rejected for delivery. Check the returned model’s status fields.
public struct HelixEndpoint<Response>: Sendable {
  private let baseURL = URL(string: "https://api.twitch.tv/helix")!

  private let authentication: HelixAuthentication
  internal let method: String
  internal let path: String

  private let makeQueryItems: @Sendable (TwitchCredentials) throws -> [(String, String?)]
  private let makeBody: @Sendable (TwitchCredentials) throws -> Encodable?
  private let processResponse:
    @Sendable (Data, HelixResponseMetadata, JSONDecoder, (any Error) -> Void) throws -> Response

  internal init<Payload: Decodable & Sendable>(
    method: String, path: String,
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil },
    responseType: Payload.Type,
    makeResponse:
      @escaping @Sendable (DecodedHelixResponse<Payload>) throws -> Response
  ) {
    self.authentication = authentication
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.processResponse = { data, metadata, decoder, onMalformedPagination in
      let payload: HelixResponsePayload<Payload>
      do {
        payload = try decoder.decode(HelixResponsePayload<Payload>.self, from: data)
      } catch is CancellationError {
        throw CancellationError()
      } catch {
        throw HelixError.parsingResponseFailed(
          .init(underlyingError: error, responseData: data, metadata: metadata))
      }

      if let error = payload.paginationFailure { onMalformedPagination(error) }
      return try makeResponse(DecodedHelixResponse(payload: payload, rawData: data))
    }
  }

  internal init(
    method: String, path: String,
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil },
    makeRawResponse: @escaping @Sendable (Data) throws -> Response
  ) {
    self.authentication = authentication
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.processResponse = { data, metadata, _, _ in
      do {
        return try makeRawResponse(data)
      } catch let error as DecodingError {
        throw HelixError.parsingResponseFailed(
          .init(underlyingError: error, responseData: data, metadata: metadata))
      }
    }
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

  internal func makeResponse(
    from data: Data, metadata: HelixResponseMetadata, decoder: JSONDecoder,
    onMalformedPagination: (any Error) -> Void
  ) throws -> Response {
    try processResponse(data, metadata, decoder, onMalformedPagination)
  }
}

extension HelixEndpoint where Response == Void {
  internal init(
    method: String, path: String,
    authentication: HelixAuthentication,
    queryItems: @escaping @Sendable (TwitchCredentials) throws -> [(String, String?)] = {
      _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) throws -> Encodable? = { _ in nil }
  ) {
    self.init(
      method: method, path: path, authentication: authentication, queryItems: queryItems,
      body: body,
      makeRawResponse: { data in
        guard data.isEmpty else {
          throw HelixError.nonEmptyResponse(responseData: data)
        }
        return ()
      })
  }
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
