import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public final class Helix {
  private let baseURL = URL(string: "https://api.twitch.tv/helix/")!

  private let authentication: TwitchCredentials
  private let session: URLSession

  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  internal let authenticatedUserId: String

  public init(authentication: TwitchCredentials, urlSession: URLSession? = nil) throws {
    guard authentication.clientID != nil else { throw HelixError.missingClientID }
    guard let authenticatedUserId = authentication.userId else {
      throw HelixError.missingUserID
    }

    self.authentication = authentication
    self.authenticatedUserId = authenticatedUserId

    self.session = urlSession ?? URLSession(configuration: .default)

    self.encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    self.decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
  }

  internal func request<T: Decodable>(
    _ request: HelixRequest, with queryItems: [URLQueryItem]? = nil,
    jsonBody: Encodable? = nil
  ) async throws -> (rawResponse: String, result: HelixData<T>?) {
    var urlRequest = self.buildURLRequest(request, queryItems: queryItems)

    urlRequest.allHTTPHeaderFields = try? authentication.httpHeaders()

    if let jsonBody {
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = try encoder.encode(jsonBody)
    }

    let (statusCode, data) = try await self.send(urlRequest)

    guard statusCode == 200 else {
      let rawResponse: String = String(decoding: data, as: UTF8.self)
      return (rawResponse, nil)
    }

    return try self.decode(data)
  }

  private func send(_ request: URLRequest) async throws -> (statusCode: Int, data: Data) {
    let (data, response) = try await self.session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      let error = try? decoder.decode(TwitchError.self, from: data)

      guard let error else {
        let rawResponse = String(decoding: data, as: UTF8.self)
        throw HelixError.invalidErrorResponse(
          status: httpResponse.statusCode, rawResponse: rawResponse)
      }

      throw HelixError.requestFailed(
        error: error.error, status: error.status, message: error.message)
    }

    return (httpResponse.statusCode, data)
  }

  private func decode<T: Decodable>(_ data: Data) throws -> ((String, HelixData<T>)) {
    let helixData = try? decoder.decode(HelixData<T>.self, from: data)
    let rawResponse = String(decoding: data, as: UTF8.self)

    guard let helixData else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (rawResponse, helixData)
  }

  private func buildURLRequest(_ request: HelixRequest, queryItems: [URLQueryItem]? = nil)
    -> URLRequest
  {
    let (method, endpoint) = request.unwrap()

    var urlComponents = URLComponents(string: endpoint)

    if let queryItems = queryItems, !queryItems.isEmpty {
      urlComponents?.queryItems = queryItems
    }

    let url = urlComponents?.url(relativeTo: self.baseURL)
    guard let url else { fatalError("Invalid URL") }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    return urlRequest
  }

  internal func makeQueryItems(_ items: (String, String?)...) -> [URLQueryItem] {
    return items.compactMap({ (name, value) in
      guard let value else { return nil }
      return URLQueryItem(name: name, value: value)
    })
  }
}

// the FoundationNetworking implementation for Linux doesn't have
// async support yet so we need to implement it ourselves
#if canImport(FoundationNetworking)
  extension URLSession {
    fileprivate func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: request) { data, response, error in
          if let data, let response {
            continuation.resume(returning: (data, response))
          } else if let error {
            continuation.resume(throwing: error)
          } else {
            fatalError()
          }
        }

        task.resume()
      }
    }
  }
#endif
