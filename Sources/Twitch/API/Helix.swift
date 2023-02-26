import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

open class Helix {
  private let baseURL = URL(string: "https://api.twitch.tv/helix/")!

  private let session: URLSession

  public init(authentication: TwitchAuthentication) throws {
    if authentication.clientID == nil {
      throw HelixError.missingClientID
    }

    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = authentication.httpHeaders()
    self.session = URLSession(configuration: configuration)
  }

  internal func request(_ request: HelixRequest, with queryItems: [URLQueryItem]) async throws
    -> Data
  {
    let (method, endpoint) = request.unwrap()

    guard var urlComponents = URLComponents(string: endpoint) else {
      fatalError("Invalid URL")
    }

    urlComponents.queryItems = queryItems
    guard let url = urlComponents.url(relativeTo: self.baseURL) else {
      fatalError("Invalid URL")
    }

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

      guard let error = error else {
        let rawResponse = String(decoding: data, as: UTF8.self)
        throw HelixError.invalidErrorResponse(
          status: httpResponse.statusCode, rawResponse: rawResponse)
      }

      throw error
    }

    return data
  }
}

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
