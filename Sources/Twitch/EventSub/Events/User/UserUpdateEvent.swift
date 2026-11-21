/// An EventSub notification delivered when a user updates their account.
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

  /// Creates a `UserUpdateEvent` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    description: String,
    email: String? = nil,
    emailVerified: Bool? = nil
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.description = description
    self.email = email
    self.emailVerified = emailVerified
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case description
    case email
    case emailVerified
  }
}
