#if canImport(FoundationNetworking)
  import FoundationNetworking

  extension URLSessionWebSocketTask {
    func receive(completionHandler: @Sendable @escaping (Result<Message, Error>) -> Void)
    {
      Task {
        do {
          let message = try await self.receive()
          completionHandler(.success(message))
        } catch {
          completionHandler(.failure(error))
        }
      }
    }
  }

#endif
