import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct HelixEndpoint<Response: ResponseType> {
  private let baseURL = URL(string: "https://api.twitch.tv/helix")!

  private let method: String
  private let path: String
  private let queryItems: [URLQueryItem]?
  private let body: Encodable?

  internal func makeRequest(using authentication: TwitchCredentials) -> URLRequest {
    var urlComponents = URLComponents(string: path)
    urlComponents?.queryItems = queryItems

    let url = urlComponents?.url(relativeTo: baseURL)
    guard let url else { fatalError("Invalid URL") }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    authentication.httpHeaders().forEach({ key, value in
      urlRequest.addValue(value, forHTTPHeaderField: key)
    })

    if let body {
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try? JSONEncoder().encode(body)
    }

    return urlRequest
  }

  internal init(
    method: String, path: String, queryItems: [URLQueryItem]? = nil,
    body: Encodable? = nil
  ) {
    self.method = method

    // TODO: fix the URLComponents assembly to not require this
    self.path = "helix/" + path

    self.queryItems = queryItems
    self.body = body
  }

  internal static func makeQueryItems(_ items: (String, String?)...) -> [URLQueryItem]? {
    let queryItems: [URLQueryItem] = items.compactMap({ key, value in
      guard let value = value else { return nil }
      return URLQueryItem(name: key, value: value)
    })

    return queryItems.isEmpty ? nil : queryItems
  }
}

public protocol ResponseType {}
public enum ResponseTypes {
  public enum Void: ResponseType {}
  public enum Array<R: Decodable>: ResponseType {}
  public enum Object<R: Decodable>: ResponseType {}
  public enum Optional<R: Decodable>: ResponseType {}
}

public typealias UserID = String
