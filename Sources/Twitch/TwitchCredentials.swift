public struct TwitchCredentials: Sendable {
  public let accessToken: String
  public let clientID: String

  public let userID: String
  public let userLogin: String

  public init(accessToken: String, clientID: String, userID: String, userLogin: String) {
    self.accessToken = String(accessToken.trimmingPrefix("oauth:"))
    self.clientID = clientID

    self.userID = userID
    self.userLogin = userLogin.lowercased()
  }

  internal func httpHeaders() -> [String: String] {
    var headers: [String: String] = [:]

    headers.updateValue(clientID, forKey: "Client-Id")
    headers.updateValue("Bearer \(self.accessToken)", forKey: "Authorization")

    return headers
  }
}
