#if canImport(FoundationNetworking)
  import FoundationNetworking

  extension URL {
    internal func appending(queryItems: [URLQueryItem]) -> URL {
      var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
      components.queryItems = (components.queryItems ?? []) + queryItems
      return components.url!
    }

    internal func appending(path: String) -> URL {
      appendingPathComponent(path)
    }
  }
#endif
