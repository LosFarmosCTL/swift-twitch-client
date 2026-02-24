import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [UserExtension], HelixResponseType == UserExtension
{
  public static func getUserExtensions() -> Self {
    return .init(
      method: "GET", path: "users/extensions/list",
      makeResponse: { $0.data })
  }
}

public struct UserExtension: Decodable, Sendable {
  public let id: String
  public let version: String
  public let name: String
  public let canActivate: Bool
  public let types: [ExtensionType]

  enum CodingKeys: String, CodingKey {
    case id
    case version
    case name
    case canActivate
    case types = "type"
  }
}

public enum ExtensionType: String, Decodable, Sendable {
  case component
  case mobile
  case overlay
  case panel
}
