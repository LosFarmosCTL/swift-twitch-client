public struct TwitchCredentials {
  public let oAuth: String
  public let clientID: String

  public let userId: String
  public let userLogin: String

  public init(oAuth: String, clientID: String, userId: String, userLogin: String) {
    self.oAuth = String(oAuth.trimmingPrefix("oauth:"))
    self.clientID = clientID

    self.userId = userId
    self.userLogin = userLogin.lowercased()
  }

  internal func httpHeaders() -> [String: String] {
    var headers: [String: String] = [:]

    headers.updateValue(clientID, forKey: "Client-Id")
    headers.updateValue("Bearer \(self.oAuth)", forKey: "Authorization")

    return headers
  }
}
