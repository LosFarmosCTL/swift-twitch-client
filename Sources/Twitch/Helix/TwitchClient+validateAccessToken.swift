import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  /// Validates an OAuth access token with Twitch.
  ///
  /// - Returns: The account identity, application client ID, granted scopes, and
  ///   remaining lifetime.
  /// - Throws: `AccessTokenValidationError.invalidToken` for a non-200 response, a
  ///   transport or decoding error, or `CancellationError` when cancelled.
  ///
  /// - Parameters:
  ///   - accessToken: The OAuth access token, without the `oauth:` prefix.
  public static func validateAccessToken(accessToken: String) async throws
    -> ValidatedAccessToken
  {
    let network = URLSessionNetworkSession(
      session: URLSession(configuration: .default))

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

    guard response.statusCode == 200 else {
      throw AccessTokenValidationError.invalidToken
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return try decoder.decode(ValidatedAccessToken.self, from: data)
  }
}

/// The token kind, optional account, application, scopes, and lifetime verified by Twitch.
public struct ValidatedAccessToken: Decodable, Sendable {
  /// The client ID of the Twitch application that issued the token.
  public let clientID: String
  /// The account’s login name, or `nil` for app access tokens.
  public var login: String? { user?.login }
  /// The Twitch user ID, or `nil` for app access tokens.
  public var userID: String? { user?.id }
  /// The token kind, including the account identity for user tokens.
  public let kind: TwitchCredentials.Kind
  /// The validated account identity, or `nil` for app access tokens.
  public var user: TwitchCredentials.UserIdentity? {
    if case .user(let identity) = kind { identity } else { nil }
  }

  /// Creates credentials using the identity verified by Twitch.
  ///
  /// Supply the same access token that was submitted for validation.
  public func credentials(accessToken: String) -> TwitchCredentials {
    .init(accessToken: accessToken, clientID: clientID, kind: kind)
  }

  /// The scopes returned by validation; this does not enumerate prior app user grants.
  public let scopes: [String]
  /// The remaining token lifetime in seconds; `nil` when Twitch omits it or reports zero.
  public let expiresIn: Int?

  enum CodingKeys: String, CodingKey {
    case clientID = "clientId"
    case userID = "userId"
    case login, scopes, expiresIn
  }

  /// Decodes token validation, mapping a zero expiration to `nil`.
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
    scopes = try container.decode([String].self, forKey: .scopes)

    let expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
    if expiresIn != 0 {
      self.expiresIn = expiresIn
    } else {
      self.expiresIn = nil
    }
  }
}

/// A failure reported when Twitch rejects an access token.
public enum AccessTokenValidationError: Error, Sendable {
  /// Twitch rejected the token validation request.
  case invalidToken
}
