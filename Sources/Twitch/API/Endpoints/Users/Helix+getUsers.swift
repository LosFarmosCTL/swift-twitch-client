import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getUsers(userIDs: [String] = [], userLogins: [String] = []) async throws
    -> [User]
  {
    let idQueryItems = userIDs.map { URLQueryItem(name: "id", value: $0) }
    let loginQueryItems = userLogins.map { URLQueryItem(name: "login", value: $0) }

    let queryItems = idQueryItems + loginQueryItems

    let (rawResponse, result): (_, HelixData<User>?) = try await self.request(
      .get("users"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
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
