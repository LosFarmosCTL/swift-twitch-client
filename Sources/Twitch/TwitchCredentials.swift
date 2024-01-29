private let oAuthPrefix = "oauth:"

public struct TwitchCredentials {
  internal let oAuth: String
  internal let clientID: String?
  internal let userId: String?

  public init(oAuth: String, clientID: String? = nil, userId: String? = nil) {
    // assure that the stored token always starts with "oauth:"
    if !oAuth.starts(with: oAuthPrefix) {
      self.oAuth = oAuthPrefix + oAuth
    } else {
      self.oAuth = oAuth
    }

    self.clientID = clientID
    self.userId = userId
  }

  private var cleanOAuth: String { return String(oAuth.dropFirst(oAuthPrefix.count)) }

  internal func httpHeaders() throws -> [String: String] {
    guard let clientID = self.clientID else { throw CredentialError.missingClientID }

    var headers: [String: String] = [:]

    headers.updateValue(clientID, forKey: "Client-Id")
    headers.updateValue("Bearer \(self.cleanOAuth)", forKey: "Authorization")

    return headers
  }
}

public enum CredentialError: Error { case missingClientID }
