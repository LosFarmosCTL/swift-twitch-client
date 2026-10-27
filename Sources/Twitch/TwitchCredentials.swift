/// The token and account identity used to access Twitch.
///
/// The client ID must belong to the application that issued the token, and the user ID
/// and login must identify its account. Initialization removes a leading `oauth:` token
/// prefix and lowercases the login; it does not validate credentials with Twitch.
///
/// For Helix endpoints requiring an Extension Backend Service (EBS) JWT, supply the
/// signed JWT as `accessToken`, the extension’s client ID as `clientID`, and the identity
/// required by the endpoint. Helix sends the JWT as a Bearer token. The library does not
/// sign JWTs; do not pass them to `TwitchClient.validateAccessToken`, which validates
/// OAuth tokens. EBS JWTs are not OAuth credentials for IRC or EventSub.
public struct TwitchCredentials: Sendable {
  /// The OAuth access token without the `oauth:` prefix, or a signed EBS JWT for
  /// Helix endpoints that require one.
  public let accessToken: String
  /// The client ID of the Twitch application that issued the OAuth token, or of the
  /// extension associated with the EBS JWT.
  public let clientID: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String

  /// Creates credentials for a Twitch user account or an EBS-JWT Helix request.
  ///
  /// Removes a leading `oauth:` prefix from the token and lowercases the login. No
  /// network validation is performed.
  ///
  /// - Parameters:
  ///   - accessToken: The OAuth access token without the `oauth:` prefix, or a signed
  ///     EBS JWT for Helix endpoints that require one.
  ///   - clientID: The OAuth application’s client ID, or the extension’s client ID
  ///     when using an EBS JWT.
  ///   - userID: The Twitch user ID required by the endpoint.
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
