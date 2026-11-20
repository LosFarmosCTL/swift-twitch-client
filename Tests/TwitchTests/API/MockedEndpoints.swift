import Foundation

@testable import Twitch

extension HelixEndpoint where Response == String? {
  public static func custom(
    method: String, path: String, queryItems: [URLQueryItem]? = nil,
    body: [String: String]? = nil
  ) -> Self {
    return .init(
      method: method, path: path,
      authentication: .either,
      queryItems: { _ in
        queryItems.map {
          $0.map { ($0.name, $0.value) }
        } ?? []
      }, body: { _ in body },
      responseType: String.self, makeResponse: { $0.data.first })
  }
}
