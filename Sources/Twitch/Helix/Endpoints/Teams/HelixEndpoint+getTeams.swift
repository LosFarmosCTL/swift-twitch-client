import Foundation

extension HelixEndpoint {
  /// Gets a Twitch team by ID or name.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/teams/#get-teams
  /// ) for request limits and account requirements.
  ///
  /// Specify either `teamName` or `teamID`, but not both. Twitch rejects requests with
  /// neither selector or with both selectors. This factory does not validate the
  /// selection.
  ///
  /// - Parameters:
  ///   - teamName: The name of the team, when provided.
  ///   - teamID: The identifier of the team, when provided.
  public static func getTeams(
    teamName: String? = nil,
    teamID: String? = nil
  ) -> HelixEndpoint<[Team]> {
    .init(
      method: "GET", path: "teams",
      authentication: .either,
      queryItems: { _ in
        [
          ("name", teamName),
          ("id", teamID),
        ]
      },
      responseType: Team.self, makeResponse: { $0.data })
  }
}

/// A Twitch team’s identity, branding, and member list.
public struct Team: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name of the team.
  public let teamName: String
  /// The team’s display name shown to viewers.
  public let teamDisplayName: String

  /// The team’s description, which may contain HTML.
  public let info: String
  /// The URL of the team's thumbnail image, when provided.
  public let thumbnailURL: String?
  /// The URL of the team's background image, when provided.
  public let backgroundImageURL: String?
  /// The team banner image, when provided.
  public let banner: String?
  /// The time the resource was created.
  public let createdAt: Date?
  /// The time the resource was last updated.
  public let updatedAt: Date?

  /// The team’s member broadcasters; omitted by the channel-teams endpoint.
  public let users: [TeamMember]?
  /// The Twitch user ID of the broadcaster, when provided.
  public let broadcasterID: String?
  /// The login name of the broadcaster, when provided.
  public let broadcasterLogin: String?
  /// The display name of the broadcaster, when provided.
  public let broadcasterDisplayName: String?

  /// Creates a `Team` value.
  public init(
    id: String,
    teamName: String,
    teamDisplayName: String,
    info: String,
    thumbnailURL: String? = nil,
    backgroundImageURL: String? = nil,
    banner: String? = nil,
    createdAt: Date? = nil,
    updatedAt: Date? = nil,
    users: [TeamMember]? = nil,
    broadcasterID: String? = nil,
    broadcasterLogin: String? = nil,
    broadcasterDisplayName: String? = nil
  ) {
    self.id = id
    self.teamName = teamName
    self.teamDisplayName = teamDisplayName
    self.info = info
    self.thumbnailURL = thumbnailURL
    self.backgroundImageURL = backgroundImageURL
    self.banner = banner
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.users = users
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case id
    case teamName
    case teamDisplayName
    case info
    case thumbnailURL = "thumbnailUrl"
    case backgroundImageURL = "backgroundImageUrl"
    case banner
    case createdAt
    case updatedAt
    case users
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
  }
}

/// A broadcaster belonging to a Twitch team.
public struct TeamMember: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// Creates a `TeamMember` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
