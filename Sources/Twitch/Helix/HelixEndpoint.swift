import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct HelixEndpoint<
  ResponseType, HelixResponseType: Decodable,
  EndpointResponseType: HelixEndpointResponseType
> {
  private let baseURL = URL(string: "https://api.twitch.tv/helix")!

  private let method: String
  private let path: String

  private let makeQueryItems: (TwitchCredentials) -> [String: String?]
  private let makeBody: (TwitchCredentials) -> Encodable?
  private let makeResponse: (HelixResponse<HelixResponseType>) throws -> ResponseType

  internal init(
    method: String, path: String,
    queryItems: @escaping (TwitchCredentials) -> [String: String?] = { _ in [:] },
    body: @escaping (TwitchCredentials) -> Encodable? = { _ in nil },
    makeResponse: @escaping (HelixResponse<HelixResponseType>) throws -> ResponseType
  ) {
    self.method = method

    // TODO: fix the URLComponents assembly to not require this
    self.path = "helix/" + path

    self.makeQueryItems = queryItems
    self.makeBody = body
    self.makeResponse = makeResponse
  }

  internal func makeRequest(using authentication: TwitchCredentials) -> URLRequest {
    var urlComponents = URLComponents(string: path)

    let queryItems: [URLQueryItem] =
      makeQueryItems(authentication).compactMap({ pair in
        guard let value = pair.value else { return nil }
        return URLQueryItem(name: pair.key, value: value)
      })

    urlComponents?.queryItems = !queryItems.isEmpty ? queryItems : nil

    let url = urlComponents?.url(relativeTo: baseURL)
    guard let url else { fatalError("Invalid URL") }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    authentication.httpHeaders().forEach({ key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    })

    if let body = makeBody(authentication) {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try? JSONEncoder().encode(body)
    }

    return urlRequest
  }

  internal func makeResponse(from response: HelixResponse<HelixResponseType>) throws
    -> ResponseType
  {
    try makeResponse(response)
  }
}

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  private init(
    method: String, path: String,
    queryItems: @escaping (TwitchCredentials) -> [String: String?] = { _ in [:] },
    body: @escaping (TwitchCredentials) -> Encodable? = { _ in nil }
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
}

public struct VoidResponse: Decodable {}

public typealias UserID = String
public typealias PaginationCursor = String
