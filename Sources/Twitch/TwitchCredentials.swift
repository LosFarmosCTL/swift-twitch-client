/// Credentials used to authorize Twitch OAuth and Extension Backend Service requests.
///
/// `TwitchCredentials` wraps one of three authentication kinds (``Kind``):
/// - A user OAuth access token carrying a ``UserIdentity`` (required for direct
///   EventSub WebSockets, authenticated IRC, and user-scoped Helix endpoints).
/// - An app OAuth access token created with ``app(accessToken:clientID:)``.
/// - An externally signed Extension Backend Service (EBS) JWT created with
///   ``extensionJWT(token:clientID:)``.
///
/// Creating credentials normalizes the token (stripping a leading `oauth:` prefix) and
/// lowercases the user login without contacting Twitch. To validate an OAuth token and
/// populate its identity and granted ``scopes`` automatically, call
/// ``TwitchClient/validateAccessToken(accessToken:)`` and convert the result with
/// ``ValidatedAccessToken/credentials(accessToken:)``.
///
/// - Note: The library does not obtain or refresh OAuth tokens or sign Extension JWTs.
///   Call ``TwitchClient/switchCredentials(to:chatBehavior:)`` when your app refreshes
///   or changes tokens.
/// - SeeAlso: <doc:Authentication>, ``TwitchAuthenticationError``
public struct TwitchCredentials: Sendable {
  /// The authentication mechanism represented by a ``TwitchCredentials`` value.
  public enum Kind: Sendable, Equatable {
    /// A user OAuth access token authorized by the associated Twitch account.
    case user(UserIdentity)
    /// An app OAuth access token representing the issuing application without a user.
    case app
    /// An externally signed Extension Backend Service (EBS) JWT, separate from OAuth.
    case extensionJWT
  }

  /// The Twitch account that authorized a user OAuth access token.
  public struct UserIdentity: Sendable, Equatable {
    /// The authorized account's numeric Twitch user ID.
    public let id: String
    /// The authorized account's lowercase login name.
    public let login: String

    /// Creates an account identity, normalizing `login` to lowercase.
    ///
    /// - Parameters:
    ///   - id: The account's Twitch user ID.
    ///   - login: The account's login name. Normalized to lowercase.
    public init(id: String, login: String) {
      self.id = id
      self.login = login.lowercased()
    }
  }

  /// The bearer token without any leading `oauth:` prefix, or an externally signed EBS JWT.
  public let accessToken: String
  /// The issuing OAuth application's client ID, or the extension's client ID for an EBS JWT.
  public let clientID: String
  /// Whether these credentials represent a user OAuth token, app OAuth token, or EBS JWT.
  public let kind: Kind
  /// The granted OAuth scopes for this token, if known.
  ///
  /// A `nil` value means scopes are unknown rather than empty. Helix and EventSub always
  /// let Twitch enforce scopes on the server, while optional scope-gated managed chat
  /// features (such as ``ChatConfiguration/moderationEnrichment`` and
  /// ``ChatConfiguration/prefillModeratedChannels``) only activate when the required
  /// scopes are positively known to be present.
  public let scopes: Set<String>?

  /// The authorized account identity, or `nil` for app tokens and Extension JWTs.
  public var user: UserIdentity? {
    if case .user(let identity) = kind { identity } else { nil }
  }

  /// The authorized account's Twitch user ID, or `nil` for app tokens and Extension JWTs.
  public var userID: String? { user?.id }
  /// The authorized account's lowercase login, or `nil` for app tokens and Extension JWTs.
  public var userLogin: String? { user?.login }

  /// Creates credentials for an authenticated Twitch user account.
  ///
  /// - Parameters:
  ///   - accessToken: The user OAuth access token. Any leading `oauth:` prefix is stripped.
  ///   - clientID: The client ID of the Twitch application that issued the token.
  ///   - userID: The authorized account's Twitch user ID.
  ///   - userLogin: The authorized account's login name. Normalized to lowercase.
  ///   - scopes: Known granted OAuth scopes, or `nil` if unknown. Pass scopes (or construct
  ///     credentials via ``ValidatedAccessToken/credentials(accessToken:)``) when using
  ///     scope-gated managed chat features.
  public init(
    accessToken: String, clientID: String, userID: String, userLogin: String,
    scopes: Set<String>? = nil
  ) {
    self.init(
      accessToken: accessToken, clientID: clientID,
      kind: .user(.init(id: userID, login: userLogin)), scopes: scopes)
  }

  /// Creates credentials with an explicit authentication kind.
  ///
  /// - Parameters:
  ///   - accessToken: The OAuth access token or externally signed EBS JWT. Any leading
  ///     `oauth:` prefix is stripped.
  ///   - clientID: The issuing application or extension client ID.
  ///   - kind: The credential kind (user OAuth, app OAuth, or Extension JWT).
  ///   - scopes: Known granted OAuth scopes, or `nil` if unknown.
  public init(
    accessToken: String, clientID: String, kind: Kind, scopes: Set<String>? = nil
  ) {
    self.accessToken = String(accessToken.trimmingPrefix("oauth:"))
    self.clientID = clientID
    self.kind = kind
    self.scopes = scopes
  }

  /// Creates app OAuth credentials from an existing client-credentials token.
  ///
  /// App tokens represent an application rather than a signed-in user. Obtaining and
  /// replacing expired app tokens remains the caller's responsibility.
  ///
  /// - Parameters:
  ///   - accessToken: The app OAuth access token. Any leading `oauth:` prefix is stripped.
  ///   - clientID: The client ID of the Twitch application that issued the token.
  /// - Returns: Credentials configured with ``Kind/app``.
  public static func app(accessToken: String, clientID: String) -> Self {
    .init(accessToken: accessToken, clientID: clientID, kind: .app)
  }

  /// Creates credentials for an externally signed Extension Backend Service (EBS) JWT.
  ///
  /// Your backend must sign the JWT with the claims required by the target extension
  /// endpoint. The client sends the token as a `Bearer` header without validating or
  /// signing its claims. Extension JWT credentials authorize only JWT-compatible Helix
  /// endpoints and cannot be used with OAuth-only endpoints, token validation, EventSub,
  /// or IRC.
  ///
  /// - Parameters:
  ///   - token: The externally signed EBS JWT.
  ///   - clientID: The Twitch extension's client ID.
  /// - Returns: Credentials configured with ``Kind/extensionJWT``.
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
