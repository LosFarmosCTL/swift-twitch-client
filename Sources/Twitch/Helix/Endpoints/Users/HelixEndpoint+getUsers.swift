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
  let id: String
  let login: String
  let displayName: String

  let type: String
  let broadcasterType: BroadcasterType

  let description: String
  let profileImageUrl: String
  let offlineImageUrl: String
  let createdAt: Date

  let email: String?

  enum BroadcasterType: String, Decodable {
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
