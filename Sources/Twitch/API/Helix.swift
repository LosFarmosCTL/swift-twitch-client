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
    configuration.httpAdditionalHeaders = authentication.HTTPHeaders()
    self.session = URLSession(configuration: configuration)
  }

  private func request(at endpoint: String, with queryItems: [URLQueryItem]) async throws -> Data {
    guard var urlComponents = URLComponents(string: endpoint) else {
      fatalError("Invalid URL")
    }

    urlComponents.queryItems = queryItems
    guard let url = urlComponents.url(relativeTo: self.baseURL) else {
      fatalError("Invalid URL")
    }

    let (data, response) = try await self.session.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard httpResponse.statusCode == 200 else {
      throw HelixError.non2XXStatusCode(httpResponse.statusCode)
    }

    return data
  }
}

#if canImport(FoundationNetworking)
  extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
      return try await withCheckedThrowingContinuation { continuation in
        let task = self.dataTask(with: url) { data, response, error in
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
