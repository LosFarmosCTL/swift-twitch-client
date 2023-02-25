internal enum HelixRequest {
  case get(_ endpoint: String)
  case post(_ endpoint: String)
  case put(_ endpoint: String)
  case patch(_ endpoint: String)
  case delete(_ endpoint: String)

  func unwrap() -> (method: String, endpoint: String) {
    switch self {
    case .get(let endpoint): return ("GET", endpoint)
    case .post(let endpoint): return ("POST", endpoint)
    case .put(let endpoint): return ("PUT", endpoint)
    case .patch(let endpoint): return ("PATCH", endpoint)
    case .delete(let endpoint): return ("DELETE", endpoint)
    }
  }
}
