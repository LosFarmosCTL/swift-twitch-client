import MemberwiseInit

/// An EventSub notification delivered when a user updates their account.
@MemberwiseInit(.public)
public struct UserUpdateEvent: Event {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The descriptive text supplied by Twitch.
  public let description: String

  /// The user’s email address, when authorized.
  public let email: String?
  /// Whether the email address has been verified, when provided.
  public let emailVerified: Bool?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case description
    case email
    case emailVerified
  }
}
