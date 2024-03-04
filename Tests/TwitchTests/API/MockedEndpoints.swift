import Foundation

@testable import Twitch

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == String?, HelixResponseType == String
{
  public static func custom(
    method: String, path: String, queryItems: [URLQueryItem]? = nil,
    body: [String: String]? = nil
  ) -> Self {
    return .init(
      method: method, path: path,
      queryItems: { _ in
        queryItems.map {
          $0.map { ($0.name, $0.value) }
        } ?? []
      }, body: { _ in body },
      makeResponse: { $0.data.first })
  }
}
