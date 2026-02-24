import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == UserActiveExtensions, HelixResponseType == UserActiveExtensions
{
  public static func getUserActiveExtensions(userID: String? = nil) -> Self {
    return .init(
      method: "GET", path: "users/extensions",
      queryItems: { auth in
        [
          ("user_id", userID ?? auth.userID)
        ]
      },
      makeResponse: {
        guard let activeExtensions = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return activeExtensions
      })
  }
}

public struct UserActiveExtensions: Decodable, Sendable {
  public let panel: [String: ExtensionSlot]?
  public let overlay: [String: ExtensionSlot]?
  public let component: [String: ExtensionSlot]?
}

// swiftlint:disable identifier_name
public struct ExtensionSlot: Decodable, Sendable {
  public let isActive: Bool
  public let id: String?
  public let version: String?
  public let name: String?
  public let x: Int?
  public let y: Int?

  enum CodingKeys: String, CodingKey {
    case isActive = "active"
    case id, version, name
    case x, y
  }
}
// swiftlint:enable identifier_name
