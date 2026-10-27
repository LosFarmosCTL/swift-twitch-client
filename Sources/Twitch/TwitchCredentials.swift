/// Credentials for Twitch OAuth and Extension Backend Service requests.
///
/// Initialization normalizes the token and identity without contacting Twitch. Use
/// ``TwitchClient/validateAccessToken(accessToken:)`` to validate an OAuth token.
/// Extension JWTs must be signed externally and cannot be validated by that endpoint.
public struct TwitchCredentials: Sendable {
  /// The authentication mechanism represented by these credentials.
  public enum Kind: Sendable, Equatable {
    /// A token authorized by the associated Twitch account.
    case user(UserIdentity)
    /// A token representing the issuing application, without a user account.
    case app
    /// An externally signed Extension Backend Service JWT, separate from OAuth.
    case extensionJWT
  }

  /// The account that authorized a user access token.
  public struct UserIdentity: Sendable, Equatable {
    /// The authorized account’s Twitch user ID.
    public let id: String
    /// The authorized account’s lowercase login.
    public let login: String

    /// Creates an account identity, normalizing the login to lowercase.
    public init(id: String, login: String) {
      self.id = id
      self.login = login.lowercased()
    }
  }

  /// The OAuth token without a leading `oauth:` prefix, or an externally signed EBS JWT.
  public let accessToken: String
  /// The issuing OAuth application’s client ID, or the extension’s client ID for an EBS JWT.
  public let clientID: String
  /// Whether these credentials represent an OAuth user, OAuth app, or Extension JWT.
  public let kind: Kind

  /// The authorized account, or `nil` for app tokens and Extension JWTs.
  public var user: UserIdentity? {
    if case .user(let identity) = kind { identity } else { nil }
  }

  /// The authorized account ID, or `nil` for app tokens and Extension JWTs.
  public var userID: String? { user?.id }
  /// The authorized account login, or `nil` for app tokens and Extension JWTs.
  public var userLogin: String? { user?.login }

  /// Creates credentials for an authenticated Twitch account.
  public init(accessToken: String, clientID: String, userID: String, userLogin: String) {
    self.init(
      accessToken: accessToken, clientID: clientID,
      kind: .user(.init(id: userID, login: userLogin)))
  }

  /// Creates credentials with an explicit token kind.
  public init(accessToken: String, clientID: String, kind: Kind) {
    self.accessToken = String(accessToken.trimmingPrefix("oauth:"))
    self.clientID = clientID
    self.kind = kind
  }

  /// Creates app credentials from an existing token.
  ///
  /// Obtaining or replacing an expired token remains the caller’s responsibility.
  public static func app(accessToken: String, clientID: String) -> Self {
    .init(accessToken: accessToken, clientID: clientID, kind: .app)
  }

  /// Creates credentials for an externally signed Extension Backend Service JWT.
  ///
  /// The caller signs the JWT with the endpoint’s required claims. These credentials
  /// can only authorize JWT-compatible Helix requests, not IRC or EventSub.
  public static func extensionJWT(token: String, clientID: String) -> Self {
    .init(accessToken: token, clientID: clientID, kind: .extensionJWT)
  }

  internal func requireUser() throws -> UserIdentity {
    guard let user else { throw TwitchAuthenticationError.userAccessTokenRequired }
    return user
  }

  /// Resolves a request actor independently of the credential's identity.
  internal func resolveUserID(
    _ explicitID: String?, parameter: String, matchingToken: Bool = false
  ) throws -> String {
    guard let id = explicitID ?? userID, !id.isEmpty else {
      throw TwitchAuthenticationError.missingUserID(parameter: parameter)
    }
    if matchingToken, let user, user.id != id {
      throw TwitchAuthenticationError.userIDMismatch(parameter: parameter)
    }

    return id
  }

  internal func httpHeaders() -> [String: String] {
    ["Client-Id": clientID, "Authorization": "Bearer \(accessToken)"]
  }
}
