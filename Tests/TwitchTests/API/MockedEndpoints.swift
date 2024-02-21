import Foundation

@testable import Twitch

extension HelixEndpoint where Response == ResponseTypes.Object<String> {
  public static func custom(
    method: String, path: String, queryItems: [URLQueryItem]? = nil,
    body: [String: String]? = nil
  ) -> Self {
    return .init(method: method, path: path, queryItems: queryItems, body: body)
  }
}
