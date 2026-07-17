import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  public static func validateToken(token: String) async throws -> ValidatedToken {
    let network = URLSessionNetworkSession(
      session: URLSession(configuration: .default))

    return try await validateToken(token: token, network: network)
  }

  internal static func validateToken(
    token: String,
    network: NetworkSession
  ) async throws -> ValidatedToken {
    let url = URL(string: "https://id.twitch.tv/oauth2/validate")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

    let (data, response): (Data, HTTPURLResponse)
    do {
      (data, response) = try await network.data(for: request)
    } catch let error as URLError where error.code == .cancelled {
      throw CancellationError()
    } catch let error as CancellationError {
      throw error
    }

    guard response.statusCode == 200 else {
      throw ValidationError.invalidToken
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return try decoder.decode(ValidatedToken.self, from: data)
  }
}

public struct ValidatedToken: Decodable, Sendable {
  public let clientID: String
  public let login: String
  public let userID: String
  public let scopes: [String]
  public let expiresIn: Int?

  enum CodingKeys: String, CodingKey {
    case clientID = "clientId"
    case userID = "userId"
    case login, scopes, expiresIn
  }

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

public enum ValidationError: Error, Sendable {
  case invalidToken
}
