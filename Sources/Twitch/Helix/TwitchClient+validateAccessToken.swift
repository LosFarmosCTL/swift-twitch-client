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
    request.addValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")

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

/// The account, application, scopes, and lifetime returned by Twitch token validation.
public struct ValidatedAccessToken: Decodable, Sendable {
  /// The client ID of the Twitch application that issued the token.
  public let clientID: String
  /// The account’s login name.
  public let login: String
  /// The Twitch user ID.
  public let userID: String
  /// The OAuth scopes granted to the access token.
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
    userID = try container.decode(String.self, forKey: .userID)
    login = try container.decode(String.self, forKey: .login)
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
