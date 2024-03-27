import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [User], HelixResponseType == User
{
  public static func getUsers(ids: [UserID] = [], names: [String] = []) -> Self {
    let idQueryItems = ids.map { ("id", $0) }
    let loginQueryItems = names.map { ("login", $0) }

    return .init(
      method: "GET", path: "users",
      queryItems: { _ in idQueryItems + loginQueryItems },
      makeResponse: { $0.data })
  }
}

public struct User: Decodable {
  public let id: String
  public let login: String
  public let displayName: String

  public let type: String
  public let broadcasterType: BroadcasterType

  public let description: String
  public let profileImageUrl: String
  public let offlineImageUrl: String
  public let createdAt: Date

  public let email: String?

  public enum BroadcasterType: String, Decodable {
    case partner
    case affiliate
    case none = ""
  }

  enum CodingKeys: String, CodingKey {
    case id
    case login
    case displayName = "display_name"

    case type
    case broadcasterType = "broadcaster_type"

    case description
    case profileImageUrl = "profile_image_url"
    case offlineImageUrl = "offline_image_url"
    case createdAt = "created_at"

    case email
  }
}
