import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension TwitchClient {
  public static func validateToken(token: String) async throws -> ValidatedToken {
    let urlSession = URLSession(configuration: .default)
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

    var request = URLRequest(url: URL(string: "https://id.twitch.tv/oauth2/validate")!)
    request.addValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

    let (data, response) = try await urlSession.data(for: request)

    // swiftlint:disable:next force_cast
    let httpResponse = response as! HTTPURLResponse
    guard (200) ~= httpResponse.statusCode else { throw ValidationError.invalidToken }

    return try jsonDecoder.decode(ValidatedToken.self, from: data)
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
