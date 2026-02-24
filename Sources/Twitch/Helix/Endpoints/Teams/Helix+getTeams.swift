import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Team], HelixResponseType == Team
{
  public static func getTeams(name: String? = nil, id: String? = nil) -> Self {
    return .init(
      method: "GET", path: "teams",
      queryItems: { _ in
        [
          ("name", name),
          ("id", id),
        ]
      },
      makeResponse: { $0.data })
  }
}

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
  public let broadcasterName: String?

  enum CodingKeys: String, CodingKey {
    case id, teamName, teamDisplayName

    case info
    case thumbnailURL = "thumbnailUrl"
    case backgroundImageURL = "backgroundImageUrl"
    case banner
    case createdAt, updatedAt

    case users
    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName
  }
}

public struct TeamMember: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName
  }
}
