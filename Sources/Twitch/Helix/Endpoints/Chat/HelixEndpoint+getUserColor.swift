import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [UserColor],
  HelixResponseType == UserColor
{
  public static func getUserColors(of users: [UserID]) -> Self {
    return .init(
      method: "GET", path: "chat/color",
      queryItems: { _ in
        users.map { ("user_id", $0) }
      }, makeResponse: { $0.data })
  }
}

public struct UserColor: Decodable {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let color: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName, color
  }
}
