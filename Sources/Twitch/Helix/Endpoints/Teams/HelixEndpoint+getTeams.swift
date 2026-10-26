import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a Twitch team by ID or name.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-teams
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
  ) -> HelixEndpoint<[Team], Team, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "teams",
      queryItems: { _ in
        [
          ("name", teamName),
          ("id", teamID),
        ]
      },
      makeResponse: { $0.data })
  }
}

/// A Twitch team’s identity, branding, and member list.
@MemberwiseInit(.public)
public struct Team: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name of the team.
  public let teamName: String
  /// The team’s display name shown to viewers.
  public let teamDisplayName: String

  /// The team’s description, which may contain HTML.
  public let info: String
  /// The URL for thumbnail.
  public let thumbnailURL: String
  /// The URL for background image, when provided.
  public let backgroundImageURL: String?
  /// The team banner image, when provided.
  public let banner: String?
  /// The time the resource was created.
  public let createdAt: Date
  /// The time the resource was last updated.
  public let updatedAt: Date

  /// The team’s member broadcasters; omitted by the channel-teams endpoint.
  public let users: [TeamMember]?
  /// The Twitch user ID of the broadcaster, when provided.
  public let broadcasterID: String?
  /// The login name of the broadcaster, when provided.
  public let broadcasterLogin: String?
  /// The display name of the broadcaster, when provided.
  public let broadcasterDisplayName: String?

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
@MemberwiseInit(.public)
public struct TeamMember: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
