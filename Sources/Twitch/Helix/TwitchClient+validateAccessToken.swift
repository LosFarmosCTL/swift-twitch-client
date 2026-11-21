import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Validates a user or app OAuth access token against Twitch's validation endpoint.
  ///
  /// Twitch requires applications maintaining OAuth sessions to validate access tokens at
  /// startup and hourly thereafter. Call ``ValidatedAccessToken/credentials(accessToken:)``
  /// on the returned value to construct ``TwitchCredentials`` pre-populated with the
  /// verified client ID, account identity, and granted scopes.
  ///
  /// - Important: Only pass OAuth user or app access tokens to this method. Do not submit
  ///   Extension Backend Service (EBS) JWTs.
  /// - Parameters:
  ///   - accessToken: The OAuth access token. Any leading `oauth:` prefix is
  ///     stripped automatically.
  ///   - urlSession: The `URLSession` used for HTTP transport. Defaults to
  ///     `URLSession.shared`.
  /// - Returns: A ``ValidatedAccessToken`` describing the token's kind, client ID,
  ///   optional account identity, granted scopes, and remaining lifetime.
  /// - Throws: ``AccessTokenValidationError/invalidToken`` if Twitch returns HTTP 401,
  ///   ``AccessTokenValidationError/unexpectedResponse(statusCode:)`` for other non-200
  ///   HTTP statuses, a transport or decoding error, or `CancellationError` when cancelled.
  /// - SeeAlso: <doc:Authentication>, ``ValidatedAccessToken``
  public static func validateAccessToken(
    accessToken: String,
    urlSession: URLSession = .shared
  ) async throws
    -> ValidatedAccessToken
  {
    let network = URLSessionNetworkSession(session: urlSession)

    return try await validateAccessToken(accessToken: accessToken, network: network)
  }

  internal static func validateAccessToken(
    accessToken: String,
    network: NetworkSession
  ) async throws -> ValidatedAccessToken {
    let url = URL(string: "https://id.twitch.tv/oauth2/validate")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue(
      "OAuth \(String(accessToken.trimmingPrefix("oauth:")))",
      forHTTPHeaderField: "Authorization")

    let (data, response): (Data, HTTPURLResponse)
    do {
      (data, response) = try await network.data(for: request)
    } catch let error as URLError where error.code == .cancelled {
      throw CancellationError()
    } catch let error as CancellationError {
      throw error
    }

    switch response.statusCode {
    case 200: break
    case 401: throw AccessTokenValidationError.invalidToken
    default: throw AccessTokenValidationError.unexpectedResponse(statusCode: response.statusCode)
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return try decoder.decode(ValidatedAccessToken.self, from: data)
  }
}

/// Token metadata returned by ``TwitchClient/validateAccessToken(accessToken:urlSession:)``.
///
/// Contains the issuing application's ``clientID``, the token ``kind`` (user or app),
/// granted ``scopes``, and remaining lifetime (``expiresIn``). Call
/// ``credentials(accessToken:)`` with the same token to create ``TwitchCredentials``
/// carrying this verified identity and scope set.
///
/// - SeeAlso: <doc:Authentication>, ``TwitchCredentials``
public struct ValidatedAccessToken: Decodable, Sendable, Equatable {
  /// The client ID of the Twitch application that issued the token.
  public let clientID: String
  /// The authorized account's lowercase login name, or `nil` for app access tokens.
  public var login: String? { user?.login }
  /// The authorized account's Twitch user ID, or `nil` for app access tokens.
  public var userID: String? { user?.id }
  /// Whether Twitch validated a user token (with its ``TwitchCredentials/UserIdentity``)
  /// or an app token.
  public let kind: TwitchCredentials.Kind
  /// The validated account identity, or `nil` for app access tokens.
  public var user: TwitchCredentials.UserIdentity? {
    if case .user(let identity) = kind { identity } else { nil }
  }

  /// Creates ``TwitchCredentials`` populated with the identity and scopes verified by Twitch.
  ///
  /// Because ``TwitchCredentials/scopes`` is populated from ``scopes``, credentials built
  /// through this method automatically enable scope-gated managed chat features when the
  /// required scopes were granted.
  ///
  /// - Parameter accessToken: The same OAuth access token that was passed to
  ///   ``TwitchClient/validateAccessToken(accessToken:urlSession:)``.
  /// - Returns: Normalized ``TwitchCredentials`` matching the validated token.
  public func credentials(accessToken: String) -> TwitchCredentials {
    .init(accessToken: accessToken, clientID: clientID, kind: kind, scopes: Set(scopes))
  }

  /// The OAuth scopes returned by Twitch's validation endpoint.
  ///
  /// For app tokens this list is typically empty and does not enumerate earlier user
  /// authorizations granted to the application.
  public let scopes: [String]
  /// The remaining lifetime of the token in seconds, or `nil` when Twitch omits it or
  /// reports zero (for example, legacy non-expiring tokens).
  public let expiresIn: Int?

  /// Creates a `ValidatedAccessToken` value.
  public init(
    clientID: String,
    kind: TwitchCredentials.Kind,
    scopes: [String] = [],
    expiresIn: Int? = nil
  ) {
    self.clientID = clientID
    self.kind = kind
    self.scopes = scopes
    self.expiresIn = expiresIn
  }

  enum CodingKeys: String, CodingKey {
    case clientID = "clientId"
    case userID = "userId"
    case login, scopes, expiresIn
  }

  /// Decodes a Twitch OAuth validation response, mapping a zero expiration to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    clientID = try container.decode(String.self, forKey: .clientID)
    let userID = try container.decodeIfPresent(String.self, forKey: .userID)
    let login = try container.decodeIfPresent(String.self, forKey: .login)
    switch (userID, login) {
    case (nil, nil): kind = .app
    case (.some(let id), .some(let login)) where !id.isEmpty && !login.isEmpty:
      kind = .user(.init(id: id, login: login))
    default:
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: decoder.codingPath,
          debugDescription:
            "Token validation must include both user_id and login, or neither."))
    }
    if case .app = kind {
      scopes = try container.decodeIfPresent([String].self, forKey: .scopes) ?? []
    } else {
      scopes = try container.decode([String].self, forKey: .scopes)
    }

    let expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
    if expiresIn != 0 {
      self.expiresIn = expiresIn
    } else {
      self.expiresIn = nil
    }
  }
}

/// An error thrown when validating an OAuth access token against Twitch fails.
///
/// - SeeAlso: ``TwitchClient/validateAccessToken(accessToken:urlSession:)``, <doc:Authentication>
public enum AccessTokenValidationError: Error, Sendable, Equatable, Hashable {
  /// Twitch rejected the token with HTTP 401 (for example, it is expired, revoked, or
  /// malformed).
  case invalidToken
  /// Twitch returned an unexpected non-200 HTTP status code (such as HTTP 429 or 5xx).
  ///
  /// - Parameter statusCode: The HTTP status code returned by Twitch.
  case unexpectedResponse(statusCode: Int)
}

extension AccessTokenValidationError: CustomStringConvertible {
  /// A diagnostic description of the token-validation failure.
  public var description: String {
    switch self {
    case .invalidToken:
      "The access token is invalid, expired, or revoked."
    case .unexpectedResponse(let statusCode):
      "Token validation returned unexpected HTTP status \(statusCode)."
    }
  }
}

#if !os(Linux)
  extension AccessTokenValidationError: CustomLocalizedStringResourceConvertible {
    /// The localized string resource describing this error.
    public var localizedStringResource: LocalizedStringResource {
      switch self {
      case .invalidToken:
        .init("The access token is invalid, expired, or revoked.", bundle: .twitchModule)
      case .unexpectedResponse(let statusCode):
        .init(
          "Token validation returned unexpected HTTP status \(statusCode).",
          bundle: .twitchModule)
      }
    }
  }
#endif

extension AccessTokenValidationError: LocalizedError {
  /// A localized description suitable for presenting this error.
  public var errorDescription: String? {
    #if !os(Linux)
      return String(localized: self.localizedStringResource)
    #else
      return self.description
    #endif
  }
}
