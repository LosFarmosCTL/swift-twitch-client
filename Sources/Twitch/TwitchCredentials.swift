/// The OAuth token and account identity used to access Twitch.
///
/// The client ID must belong to the application that issued the token, and the user ID
/// and login must identify its account. Initialization removes a leading `oauth:` token
/// prefix and lowercases the login; it does not validate credentials with Twitch.
public struct TwitchCredentials: Sendable {
  /// The OAuth access token, without the `oauth:` prefix.
  public let accessToken: String
  /// The client ID of the Twitch application that issued the token.
  public let clientID: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String

  /// Creates credentials for a Twitch user account.
  ///
  /// Removes a leading `oauth:` prefix from the token and lowercases the login. No
  /// network validation is performed.
  ///
  /// - Parameters:
  ///   - accessToken: The OAuth access token, without the `oauth:` prefix.
  ///   - clientID: The client ID of the Twitch application that issued the token.
  ///   - userID: The Twitch user ID.
  ///   - userLogin: The user’s login name.
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
