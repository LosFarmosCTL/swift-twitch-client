import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A typed description of a Twitch Helix API request and its decoded response.
///
/// Construct an endpoint using one of the static factory methods (for example,
/// ``getUsers(userIDs:userLogins:)`` or ``sendChatMessage(in:message:replyTo:isSourceOnly:pin:senderID:)``),
/// then execute it with ``TwitchClient/helix(for:)``,
/// ``TwitchClient/helixTask(for:completionHandler:)``, or the static one-off overloads
/// on ``TwitchClient``. Creating a `HelixEndpoint` performs no network I/O.
///
/// `Response` is the value wrapped inside the returned ``HelixResponse``. Empty-body
/// endpoints use `Void`, while raw-body endpoints (such as iCalendar exports) return
/// their raw payload directly.
///
/// Before dispatching an HTTP request, the client validates the credential ``TwitchCredentials/kind``
/// and any token-dependent parameters locally, throwing
/// ``HelixError/authenticationError(_:)`` on mismatch. Scopes, account eligibility, and
/// Twitch-side parameter limits are enforced by Twitch when the request runs.
///
/// - Note: An HTTP 2xx response can still report an operation-level refusal inside its
///   payload (for example, ``ChatMessageResponse/isSent`` being `false`). Always inspect
///   operation status fields where provided.
/// - SeeAlso: <doc:Helix>, <doc:RateLimiting>, ``HelixResponse``, ``HelixError``
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
    requiresValidPagination: Bool = false,
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

      if let error = payload.paginationFailure {
        if requiresValidPagination {
          throw HelixError.parsingResponseFailed(
            .init(underlyingError: error, responseData: data, metadata: metadata))
        }
        onMalformedPagination(error)
      }
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
