import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

open class Helix {
  private let baseURL = URL(string: "https://api.twitch.tv/helix/")!

  private let session: URLSession

  public init(
    authentication: TwitchAuthentication, urlSession: URLSession? = nil
  ) throws {
    if authentication.clientID == nil { throw HelixError.missingClientID }

    var httpHeaders: [AnyHashable: Any] = authentication.httpHeaders()
    if let customSession = urlSession {
      httpHeaders.merge(
        customSession.configuration.httpAdditionalHeaders
          ?? [AnyHashable: Any]()
      ) { current, _ in current }

      self.session = customSession
    } else {
      self.session = URLSession(configuration: .default)
    }

    self.session.configuration.httpAdditionalHeaders = httpHeaders
  }

  internal func request(
    _ request: HelixRequest, with queryItems: [URLQueryItem]? = nil
  ) async throws -> Data {
    let (method, endpoint) = request.unwrap()

    var urlComponents = URLComponents(string: endpoint)

    if let queryItems = queryItems, !queryItems.isEmpty {
      urlComponents?.queryItems = queryItems
    }

    let url = urlComponents?.url(relativeTo: self.baseURL)

    guard let url else { fatalError("Invalid URL") }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = method

    return try await self.send(urlRequest)
  }

  private func send(_ request: URLRequest) async throws -> Data {
    let (data, response) = try await self.session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard httpResponse.statusCode == 200 else {
      let error = try? JSONDecoder().decode(TwitchError.self, from: data)

      guard let error else {
        let rawResponse = String(decoding: data, as: UTF8.self)
        throw HelixError.invalidErrorResponse(
          status: httpResponse.statusCode, rawResponse: rawResponse)
      }

      throw HelixError.requestFailed(
        error: error.error, status: error.status, message: error.message)
    }

    return data
  }
}

#if canImport(FoundationNetworking)
  extension URLSession {
    fileprivate func data(for request: URLRequest) async throws -> (
      Data, URLResponse
    ) {
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
