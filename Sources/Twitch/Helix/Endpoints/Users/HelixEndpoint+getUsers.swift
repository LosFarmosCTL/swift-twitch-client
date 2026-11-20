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
  /// https://dev.twitch.tv/docs/api/reference/users/#get-users
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userIDs: User IDs to look up. When both IDs and logins are empty, Twitch returns
  ///     the authenticated user. App tokens require at least one ID or login.
  ///   - userLogins: The user logins to include in the request. Defaults to `[]`.
  public static func getUsers(
    userIDs: [String] = [],
    userLogins: [String] = []
  ) -> HelixEndpoint<[User]> {
    let idQueryItems = userIDs.map { ("id", $0) }
    let loginQueryItems = userLogins.map { ("login", $0) }

    return .init(
      method: "GET", path: "users",
      authentication: .either,
      queryItems: { credentials in
        if credentials.kind == .app, userIDs.isEmpty, userLogins.isEmpty {
          throw TwitchAuthenticationError.missingUserID(parameter: "id or login")
        }
        return idQueryItems + loginQueryItems
      },
      responseType: User.self, makeResponse: { $0.data })
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
  /// The account’s broadcaster classification.
  public let broadcasterType: BroadcasterType

  /// The user's channel description ("About" bio).
  public let description: String
  /// The URL of the user's profile image.
  public let profileImageURL: String
  /// The URL of the user's offline player banner image.
  public let offlineImageURL: String
  /// The time the resource was created.
  public let createdAt: Date

  /// The user’s email address, when authorized.
  public let email: String?

  /// A Twitch broadcaster classification, preserving unfamiliar strings in `rawValue`.
  public struct BroadcasterType: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact classification string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a broadcaster classification from any string.
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    /// Decodes a broadcaster classification from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// A Twitch Partner account.
    public static let partner = Self(rawValue: "partner")
    /// A Twitch Affiliate account.
    public static let affiliate = Self(rawValue: "affiliate")
    /// No value or classification applies. Encoded as `""`.
    public static let none = Self(rawValue: "")
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
