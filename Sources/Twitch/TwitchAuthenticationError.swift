import Foundation

/// An incompatible credential or a missing token-dependent request parameter.
public enum TwitchAuthenticationError: Error, Sendable, Equatable {
  /// This operation accepts OAuth access tokens, not Extension JWTs.
  case oauthAccessTokenRequired
  /// This operation requires an authenticated Twitch account.
  case userAccessTokenRequired
  /// This operation requires application credentials.
  case appAccessTokenRequired
  /// This operation requires an Extension JWT, which OAuth credentials cannot supply.
  case extensionJWTRequired
  /// The required acting user or lookup target could not be resolved.
  case missingUserID(parameter: String)
  /// The acting user differs from the account represented by the user token.
  case userIDMismatch(parameter: String)
  /// A parameter is incompatible with the supplied token kind.
  case invalidParameter(parameter: String, reason: String)
}

extension TwitchAuthenticationError: CustomStringConvertible, LocalizedError {
  /// A diagnostic explanation of the authentication failure.
  public var description: String {
    switch self {
    case .oauthAccessTokenRequired: "An OAuth user or app access token is required."
    case .userAccessTokenRequired: "A user access token is required."
    case .appAccessTokenRequired: "An app access token is required."
    case .extensionJWTRequired:
      "This endpoint requires an Extension JWT, not an OAuth access token."
    case .missingUserID(let parameter):
      "Supply \(parameter) when using an app access token."
    case .userIDMismatch(let parameter):
      "\(parameter) must match the user access token's user ID."
    case .invalidParameter(let parameter, let reason): "Invalid \(parameter): \(reason)"
    }
  }

  /// A description suitable for presenting this error.
  public var errorDescription: String? { description }
}
