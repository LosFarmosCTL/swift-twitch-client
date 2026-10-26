import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets Twitch profiles by user ID or login name.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// Email is available only for the authorized user with `user:read:email`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-users
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userIDs: User IDs to look up. When both IDs and logins are empty, Twitch returns
  ///     the authenticated user.
  ///   - userLogins: The user logins to include in the request. Defaults to `[]`.
  public static func getUsers(
    userIDs: [String] = [],
    userLogins: [String] = []
  ) -> HelixEndpoint<[User], User, HelixEndpointResponseTypes.Normal> {
    let idQueryItems = userIDs.map { ("id", $0) }
    let loginQueryItems = userLogins.map { ("login", $0) }

    return .init(
      method: "GET", path: "users",
      queryItems: { _ in idQueryItems + loginQueryItems },
      makeResponse: { $0.data })
  }
}

/// A Twitch account’s public profile and authorized account metadata.
@MemberwiseInit(.public)
public struct User: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  /// The user’s staff, administrator, or global moderator role; an empty string indicates
  /// a regular user.
  public let type: String
  /// The account’s broadcaster classification: partner, affiliate, or neither.
  public let broadcasterType: BroadcasterType

  /// The descriptive text supplied by Twitch.
  public let description: String
  /// The URL for profile image.
  public let profileImageURL: String
  /// The URL for offline image.
  public let offlineImageURL: String
  /// The time the resource was created.
  public let createdAt: Date

  /// The user’s email address, when authorized.
  public let email: String?

  /// Whether a Twitch account is a Partner, Affiliate, or neither.
  public enum BroadcasterType: String, Decodable, Sendable {
    /// A Twitch Partner account.
    case partner
    /// A Twitch Affiliate account.
    case affiliate
    /// No value or classification applies. Encoded as `""`.
    case none = ""
  }

  enum CodingKeys: String, CodingKey {
    case id
    case login
    case displayName
    case type
    case broadcasterType
    case description
    case profileImageURL = "profileImageUrl"
    case offlineImageURL = "offlineImageUrl"
    case createdAt
    case email
  }
}
