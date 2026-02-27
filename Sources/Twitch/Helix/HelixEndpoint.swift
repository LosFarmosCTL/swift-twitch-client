import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct HelixEndpoint<
  ResponseType, HelixResponseType: Sendable & Decodable,
  EndpointResponseType: HelixEndpointResponseType
>: Sendable {
  private let baseURL = URL(string: "https://api.twitch.tv/helix")!

  private let method: String
  private let path: String

  private let makeQueryItems: @Sendable (TwitchCredentials) -> [(String, String?)]
  private let makeBody: @Sendable (TwitchCredentials) -> Encodable?
  private let makeResponse:
    @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  private let makeRawResponse: @Sendable (Data) throws -> ResponseType

  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil },
    makeResponse:
      @escaping @Sendable (HelixResponse<HelixResponseType>) throws -> ResponseType
  ) {
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = makeResponse
    self.makeRawResponse = { _ in fatalError() }
  }

  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil },
    makeRawResponse: @escaping @Sendable (Data) throws -> ResponseType
  ) {
    self.method = method
    self.path = path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = { _ in fatalError() }
    self.makeRawResponse = makeRawResponse
  }

  internal func makeRequest(
    using authentication: TwitchCredentials,
    encoder: JSONEncoder
  ) -> URLRequest {
    var url = baseURL.appending(path: path)

    let queryItems =
      makeQueryItems(authentication).compactMap { (key, value) in
        guard let value else { return nil }
        return URLQueryItem(name: key, value: value)
      } as [URLQueryItem]

    if !queryItems.isEmpty { url = url.appending(queryItems: queryItems) }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    authentication.httpHeaders().forEach({ key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    })

    if let body = makeBody(authentication) {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try? encoder.encode(body)
    }

    return urlRequest
  }

  internal func makeResponse(from response: HelixResponse<HelixResponseType>) throws
    -> ResponseType
  {
    try makeResponse(response)
  }

  internal func makeResponse(from data: Data) throws -> ResponseType {
    try makeRawResponse(data)
  }
}

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  internal init(
    method: String, path: String,
    queryItems: @escaping @Sendable (TwitchCredentials) -> [(String, String?)] = { _ in []
    },
    body: @escaping @Sendable (TwitchCredentials) -> Encodable? = { _ in nil }
  ) {
    // makeResponse should never be called on a Void endpoint!
    self.init(
      method: method, path: path, queryItems: queryItems, body: body,
      makeResponse: { _ in fatalError() })
  }
}

public protocol HelixEndpointResponseType {}
public enum HelixEndpointResponseTypes {
  public enum Void: HelixEndpointResponseType {}
  public enum Normal: HelixEndpointResponseType {}
  public enum Raw: HelixEndpointResponseType {}
}
