#if canImport(FoundationNetworking)
  import Foundation
  import FoundationNetworking

  // the FoundationNetworking implementation for Linux doesn't have
  // async support yet so we need to implement it ourselves
  extension URLSession {
    internal func data(for request: URLRequest) async throws -> (Data, URLResponse) {
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
