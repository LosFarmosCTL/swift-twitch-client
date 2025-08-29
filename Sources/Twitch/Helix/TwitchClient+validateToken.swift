import Foundation

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
  public let expiresIn: Int

  enum CodingKeys: String, CodingKey {
    case clientID = "clientId"
    case userID = "userId"
    case login, scopes, expiresIn
  }
}

public enum ValidationError: Error, Sendable {
  case invalidToken
}
