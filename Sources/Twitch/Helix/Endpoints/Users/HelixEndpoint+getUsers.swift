import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [User], HelixResponseType == User
{
  public static func getUsers(ids: [String] = [], names: [String] = []) -> Self {
    let idQueryItems = ids.map { ("id", $0) }
    let loginQueryItems = names.map { ("login", $0) }

    return .init(
      method: "GET", path: "users",
      queryItems: { _ in idQueryItems + loginQueryItems },
      makeResponse: { $0.data })
  }
}

public struct User: Decodable, Sendable {
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

  public enum BroadcasterType: String, Decodable, Sendable {
    case partner
    case affiliate
    case none = ""
  }
}
