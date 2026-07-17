#if canImport(FoundationNetworking)
  import Foundation
  import FoundationNetworking

  // the FoundationNetworking implementation for Linux doesn't have
  // async support yet so we need to implement it ourselves
  extension URLSession {
    internal func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      let taskState = URLSessionDataTaskState()

      return try await withTaskCancellationHandler {
        try Task.checkCancellation()

        return try await withCheckedThrowingContinuation { continuation in
          let task = self.dataTask(with: request) { data, response, error in
            if let error {
              continuation.resume(throwing: error)
            } else if let data, let response {
              continuation.resume(returning: (data, response))
            } else {
              continuation.resume(throwing: URLError(.unknown))
            }
          }

          let wasCancelled = taskState.store(task)
          task.resume()

          if wasCancelled {
            task.cancel()
          }
        }
      } onCancel: {
        taskState.cancel()
      }
    }
  }

  private final class URLSessionDataTaskState: @unchecked Sendable {
    private let lock = NSLock()
    private var isCancelled = false
    private var task: URLSessionDataTask?

    func store(_ task: URLSessionDataTask) -> Bool {
      lock.lock()
      defer { lock.unlock() }

      self.task = task
      return isCancelled
    }

    func cancel() {
      lock.lock()
      isCancelled = true
      let task = self.task
      lock.unlock()

      task?.cancel()
    }
  }
#endif
