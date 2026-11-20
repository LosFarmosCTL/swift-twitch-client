import Foundation

/// A pre-flight validation error indicating incompatible credentials or parameters.
///
/// The client validates credential kinds and token-dependent parameters locally before
/// sending a network request. Helix methods wrap this error in
/// ``HelixError/authenticationError(_:)``, while direct EventSub and chat entry points
/// may throw it directly.
///
/// - SeeAlso: ``TwitchCredentials``, <doc:Authentication>
public enum TwitchAuthenticationError: Error, Sendable, Equatable {
  /// The operation requires a user or app OAuth access token and rejects Extension JWTs.
  case oauthAccessTokenRequired
  /// The operation requires a user OAuth access token identifying a signed-in account.
  case userAccessTokenRequired
  /// The operation requires an app OAuth access token.
  case appAccessTokenRequired
  /// The operation requires an externally signed Extension Backend Service (EBS) JWT.
  case extensionJWTRequired
  /// A required acting user ID or lookup target was omitted for an app access token.
  ///
  /// - Parameter parameter: The Twitch query or body parameter name that must be supplied.
  case missingUserID(parameter: String)
  /// A supplied user ID does not match the account represented by the user access token.
  ///
  /// - Parameter parameter: The Twitch query or body parameter name whose value mismatched.
  case userIDMismatch(parameter: String)
  /// A request parameter or combination of parameters is invalid for the supplied token kind.
  ///
  /// - Parameters:
  ///   - parameter: The Twitch parameter name that failed validation.
  ///   - reason: A human-readable explanation of why the parameter was rejected.
  case invalidParameter(parameter: String, reason: String)
}

extension TwitchAuthenticationError: CustomStringConvertible, LocalizedError {
  /// A diagnostic explanation of the authentication or parameter-validation failure.
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
