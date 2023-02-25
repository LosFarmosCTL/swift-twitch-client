private let oAuthPrefix = "oauth:"

public struct TwitchAuthentication {
  internal let oAuth: String
  internal let clientID: String?

  public init(oAuth: String, clientID: String? = nil) {
    if !oAuth.starts(with: oAuthPrefix) {
      self.oAuth = oAuthPrefix + oAuth
    } else {
      self.oAuth = oAuth
    }

    self.clientID = clientID
  }

  private var cleanOAuth: String {
    return String(oAuth.dropFirst(oAuthPrefix.count))
  }

  internal func HTTPHeaders() -> [String: String] {
    var headers: [String: String] = [:]
    headers.updateValue("Bearer " + self.cleanOAuth, forKey: "Authorization")

    if let clientID = self.clientID {
      headers.updateValue(clientID, forKey: "Client-Id")
    }

    return headers
  }
}
