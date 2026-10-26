import Foundation
import MemberwiseInit

extension HelixEndpoint {
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

@MemberwiseInit(.public)
public struct Team: Decodable, Sendable {
  public let id: String
  public let teamName: String
  public let teamDisplayName: String

  public let info: String
  public let thumbnailURL: String
  public let backgroundImageURL: String?
  public let banner: String?
  public let createdAt: Date
  public let updatedAt: Date

  public let users: [TeamMember]?
  public let broadcasterID: String?
  public let broadcasterLogin: String?
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

@MemberwiseInit(.public)
public struct TeamMember: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
