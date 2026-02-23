public struct UserUpdateEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let description: String

  public let email: String?
  public let emailVerified: Bool?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName, description

    case email, emailVerified
  }
}
