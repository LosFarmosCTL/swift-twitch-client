import Foundation
import MemberwiseInit

extension HelixEndpoint {
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

@MemberwiseInit(.public)
public struct User: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String

  public let type: String
  public let broadcasterType: BroadcasterType

  public let description: String
  public let profileImageURL: String
  public let offlineImageURL: String
  public let createdAt: Date

  public let email: String?

  public enum BroadcasterType: String, Decodable, Sendable {
    case partner
    case affiliate
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
